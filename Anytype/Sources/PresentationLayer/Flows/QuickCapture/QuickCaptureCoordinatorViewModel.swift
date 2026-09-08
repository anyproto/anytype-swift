import Foundation
import Factory
import Services
import SwiftUI
import DeepLinks
import AnytypeCore

struct QuickCaptureCreatedBanner: Equatable, Sendable {
    let objectId: String
    let spaceId: String
    let spaceName: String
    let typeName: String
}

@MainActor
@Observable
final class QuickCaptureCoordinatorViewModel {

    // MARK: - DI

    @ObservationIgnored @Injected(\.quickCaptureService)
    private var quickCaptureService: any QuickCaptureServiceProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored @Injected(\.spaceRecencyStorage)
    private var spaceRecencyStorage: any SpaceRecencyStorageProtocol
    @ObservationIgnored @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @ObservationIgnored @Injected(\.quickCaptureTypeSuggestionService)
    private var typeSuggestionService: any QuickCaptureTypeSuggestionServiceProtocol
    @ObservationIgnored
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    // MARK: - State

    var spaceView: SpaceView?
    var editorData: EditorPageObject?
    var isNotEmpty = false
    var isProcessing = false
    var draftLoadFailed = false
    private(set) var hasPublished = false
    private(set) var draftSpaceIds = Set<String>()
    var showSpacePicker = false
    var showClearDraftConfirmation = false
    var pendingSpaceSwitch: SpaceView?
    var toastBarData: ToastBarData?
    var syncStatusData: SyncStatusData?
    var syncStatusSpaceId: StringIdentifiable?
    var undoRedoObjectId: StringIdentifiable?

    @ObservationIgnored
    var dismiss: DismissAction?
    @ObservationIgnored
    private let onCreated: (QuickCaptureCreatedBanner) -> Void
    @ObservationIgnored
    private var document: (any BaseDocumentProtocol)?
    @ObservationIgnored
    private var hasTypedThisSession = false
    @ObservationIgnored
    private let inputObserver = QuickCaptureInputObserver()
    @ObservationIgnored
    private var cleanupTasks = [String: Task<Void, Never>]()
    // Only the newest draft operation may write state - a slower predecessor must
    // never land on top of the draft the user is looking at now
    @ObservationIgnored
    private var draftGeneration = 0

    @ObservationIgnored
    lazy var pageNavigation = PageNavigation(
        open: { [weak self] in
            self?.handleOpenObject(data: $0)
        },
        pushHome: { },
        pop: { },
        popToFirstInSpace: { },
        replace: { _ in },
        replaceHome: { _, _ in }
    )

    init(onCreated: @escaping (QuickCaptureCreatedBanner) -> Void) {
        self.onCreated = onCreated
    }

    var isInteractionLocked: Bool {
        isProcessing || hasPublished || pendingSpaceSwitch != nil || editorData == nil
    }

    var hasDraftsInOtherSpaces: Bool {
        draftSpaceIds.contains { $0 != spaceView?.targetSpaceId }
    }

    // Picker order only. Spaces holding unsent text come first so the dot is never buried;
    // the opening space is still chosen from `sortedEditableSpaces`, because discovery must
    // never decide where the sheet opens.
    var pickerSpaces: [SpaceView] {
        let spaces = sortedEditableSpaces
        let withDrafts = spaces.filter { draftSpaceIds.contains($0.targetSpaceId) }
        return withDrafts + spaces.filter { !draftSpaceIds.contains($0.targetSpaceId) }
    }

    var sortedEditableSpaces: [SpaceView] {
        let recency = spaceRecencyStorage.lastInteractionDates()
        return participantSpacesStorage.activeParticipantSpaces
            .filter(\.canEdit)
            .map(\.spaceView)
            .enumerated()
            .sorted { lhs, rhs in
                // 1:1 chats are conversations, not capture targets - never auto-selected, always last
                if lhs.element.isOneToOne != rhs.element.isOneToOne {
                    return !lhs.element.isOneToOne
                }
                switch (recency[lhs.element.targetSpaceId], recency[rhs.element.targetSpaceId]) {
                case let (lhsDate?, rhsDate?):
                    return lhsDate > rhsDate
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    // Keep the storage order (pinned first, then join date)
                    return lhs.offset < rhs.offset
                }
            }
            .map(\.element)
    }

    // MARK: - Lifecycle

    func onAppear() async {
        guard editorData.isNil, !isProcessing else { return }
        isProcessing = true
        draftLoadFailed = false
        defer { isProcessing = false }
        typeSuggestionService.prewarm()
        let spaces = sortedEditableSpaces
        guard let targetSpace = lastCaptureSpace(in: spaces) ?? spaces.first else {
            dismiss?()
            return
        }
        await openDraft(spaceId: targetSpace.targetSpaceId)
    }

    func discoverDrafts() async {
        // This task never selects the opening space or delays the local-pointer lookup.
        while !Task.isCancelled {
            do {
                let discovery = try await quickCaptureService.discoverDrafts()
                guard !Task.isCancelled else { return }
                if discovery.isComplete {
                    draftSpaceIds = discovery.spaceIdsWithContent
                } else {
                    draftSpaceIds.formUnion(discovery.spaceIdsWithContent)
                }
                updateCurrentDraftIndicator()
            } catch is CancellationError {
                return
            } catch {
                // Existing indicators survive unavailable stores; absence isn't evidence.
            }
            do { try await Task.sleep(for: .seconds(3)) } catch { return }
        }
    }

    func subscribeOnDraft() async {
        guard let document else { return }
        async let contentSub: () = subscribeOnContent(document: document)
        async let syncSub: () = subscribeOnSyncStatus(document: document)
        _ = await (contentSub, syncSub)
    }

    func onDismiss() async {
        inputObserver.stopObserving()
        if !hasPublished, !isProcessing, !hasTypedThisSession, let document {
            scheduleEmptyDraftCleanup(document: document)
        }
        for task in cleanupTasks.values { await task.value }
    }

    func onTapSyncStatus() {
        guard let spaceId = spaceView?.targetSpaceId else { return }
        syncStatusSpaceId = spaceId.identifiable
    }

    // MARK: - Actions

    func onTextEditingBegan(_ notification: Foundation.Notification) {
        guard !hasTypedThisSession, let textView = currentEditorTextView(notification) else { return }
        inputObserver.observe(textView) { [weak self] in
            self?.onUserInput()
        }
    }

    func onTextChanged(_ notification: Foundation.Notification) {
        guard !hasTypedThisSession, currentEditorTextView(notification) != nil else { return }
        onUserInput()
        inputObserver.stopObserving()
    }

    func onUserInput() {
        hasTypedThisSession = true
    }

    private func currentEditorTextView(_ notification: Foundation.Notification) -> UITextView? {
        guard let editorData, let textView = notification.object as? UITextView,
              textView.isFirstResponder else { return nil }
        var responder: UIResponder? = textView
        while let current = responder {
            if let editor = current as? EditorPageController {
                guard editor.viewModel?.document.objectId == editorData.objectId,
                      editor.viewModel?.document.spaceId == editorData.spaceId else { return nil }
                return textView
            }
            responder = current.next
        }
        return nil
    }

    func onTapSend() {
        guard !isInteractionLocked, isNotEmpty, let spaceView, let document else { return }
        isProcessing = true
        finishEditing()
        let spaceId = spaceView.targetSpaceId
        let objectId = document.objectId
        let analyticsType = document.details?.analyticsType ?? .custom
        let spaceName = spaceView.title
        let typeName = document.details?.objectType.displayName ?? Loc.PasteMenu.object
        Task {
            do {
                try await quickCaptureService.commitDraft(objectId: objectId, spaceId: spaceId)
            } catch {
                isProcessing = false
                toastBarData = ToastBarData(error.localizedDescription, type: .failure)
                return
            }
            hasPublished = true
            spaceRecencyStorage.markInteraction(spaceId: spaceId)
            AnytypeAnalytics.instance().logCreateObject(
                objectType: analyticsType,
                spaceId: spaceId,
                route: .quickCapture
            )
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onCreated(QuickCaptureCreatedBanner(
                objectId: objectId,
                spaceId: spaceId,
                spaceName: spaceName,
                typeName: typeName
            ))
            dismiss?()
        }
    }

    func onTapClearDraft() {
        guard !isInteractionLocked else { return }
        showClearDraftConfirmation = true
    }

    func onConfirmClearDraft() {
        guard !isInteractionLocked, let spaceId = spaceView?.targetSpaceId, let document else { return }
        isProcessing = true
        finishEditing()
        Task {
            defer { isProcessing = false }
            do {
                try await quickCaptureService.clearDraft(objectId: document.objectId, spaceId: spaceId)
            } catch {
                // The draft survived - keep showing it instead of pretending it is gone
                toastBarData = ToastBarData(Loc.QuickCapture.clearDraftFailed, type: .failure)
                return
            }
            resetDraftState()
            await openDraft(spaceId: spaceId)
        }
    }

    func onTapSpaceChip() {
        guard !isInteractionLocked else { return }
        showSpacePicker = true
    }

    func onSelectSpace(_ selected: SpaceView) {
        guard !isInteractionLocked else { return }
        showSpacePicker = false
        guard let currentSpaceId = spaceView?.targetSpaceId, selected.targetSpaceId != currentSpaceId else { return }
        isProcessing = true
        finishEditing()
        Task {
            defer { isProcessing = false }
            do {
                if QuickCaptureSpaceSwitch.action(hasContent: isNotEmpty, hasLocalEdits: hasTypedThisSession, targetHasContent: false) == .openTarget {
                    await openDraft(spaceId: selected.targetSpaceId)
                    return
                }
                let targetHoldsDraft = try await quickCaptureService.hasDraftWithContent(spaceId: selected.targetSpaceId)
                switch QuickCaptureSpaceSwitch.action(hasContent: isNotEmpty, hasLocalEdits: hasTypedThisSession, targetHasContent: targetHoldsDraft) {
                case .openTarget: await openDraft(spaceId: selected.targetSpaceId)
                case .move: await moveDraft(to: selected)
                case .confirm: pendingSpaceSwitch = selected
                }
            } catch {
                toastBarData = ToastBarData(Loc.QuickCapture.operationFailed, type: .failure)
            }
        }
    }

    func onKeepBothDrafts(_ selected: SpaceView) async {
        await resolveSpaceConflict(selected: selected, discardCurrent: false)
    }

    func onDiscardCurrentDraft(_ selected: SpaceView) async {
        await resolveSpaceConflict(selected: selected, discardCurrent: true)
    }

    private func resolveSpaceConflict(selected: SpaceView, discardCurrent: Bool) async {
        guard !isProcessing, !hasPublished, let document else { return }
        pendingSpaceSwitch = nil
        isProcessing = true
        finishEditing()
        defer { isProcessing = false }
        do {
            // Resolve the destination before giving up anything in the current space.
            await cleanupTasks[selected.targetSpaceId]?.value
            let target = try await quickCaptureService.obtainDraft(spaceId: selected.targetSpaceId)
            if discardCurrent {
                try await quickCaptureService.clearDraft(objectId: document.objectId, spaceId: document.spaceId)
            }
            setupDraft(details: target, spaceId: selected.targetSpaceId)
        } catch {
            toastBarData = ToastBarData(Loc.QuickCapture.operationFailed, type: .failure)
        }
    }

    func onCancelSpaceSwitch() {
        pendingSpaceSwitch = nil
    }

    // MARK: - Private

    // Capture reopens where capture left off, even in a 1:1 channel: the rule against
    // 1:1 is about never picking one for the user, not about forgetting one they picked
    private func lastCaptureSpace(in spaces: [SpaceView]) -> SpaceView? {
        guard let spaceId = quickCaptureService.lastCaptureSpaceId() else { return nil }
        return spaces.first { $0.targetSpaceId == spaceId }
    }

    private func moveDraft(to selected: SpaceView) async {
        guard !hasPublished, let currentSpaceId = spaceView?.targetSpaceId, let document else { return }
        let generation = beginDraftOperation()
        do {
            await cleanupTasks[selected.targetSpaceId]?.value
            let details = try await quickCaptureService.moveDraft(
                objectId: document.objectId,
                from: currentSpaceId,
                to: selected.targetSpaceId
            )
            guard isCurrentDraftOperation(generation) else { return }
            setupDraft(details: details, spaceId: selected.targetSpaceId)
        } catch QuickCaptureError.targetHasContent {
            pendingSpaceSwitch = selected
        } catch {
            guard isCurrentDraftOperation(generation) else { return }
            // The source draft is untouched on failure - the user stays on their text
            toastBarData = ToastBarData(Loc.QuickCapture.moveFailed, type: .failure)
        }
    }

    // The document's own children list drops the contents of collapsed toggles, and
    // carries the title and featured properties that the new draft recreates itself
    private func copyableBlocks(document: any BaseDocumentProtocol) -> [BlockInformation] {
        guard let root = document.infoContainer.get(id: document.objectId) else { return [] }
        var result = [BlockInformation]()
        appendCopyableBlocks(of: root, container: document.infoContainer, into: &result)
        return result
    }

    private func appendCopyableBlocks(
        of info: BlockInformation,
        container: any InfoContainerProtocol,
        into result: inout [BlockInformation]
    ) {
        for child in container.children(of: info.id) {
            if child.kind == .block, !isObjectLevelBlock(child) {
                result.append(child)
            }
            switch child.content {
            case .tableRow, .tableColumn:
                // Table internals travel with the table block itself
                break
            default:
                appendCopyableBlocks(of: child, container: container, into: &result)
            }
        }
    }

    private func isObjectLevelBlock(_ info: BlockInformation) -> Bool {
        switch info.content {
        case .featuredRelations:
            return true
        case .text(let text):
            return text.contentType == .title || text.contentType == .description
        default:
            return false
        }
    }

    private func beginDraftOperation() -> Int {
        draftGeneration += 1
        return draftGeneration
    }

    private func isCurrentDraftOperation(_ generation: Int) -> Bool {
        draftGeneration == generation
    }

    // Emptiness comes from what is actually written, not from the editorDeleteEmpty
    // flag: that flag is one-way and any details write clears it
    private func subscribeOnContent(document: any BaseDocumentProtocol) async {
        for await _ in document.syncPublisher.values {
            guard self.document?.objectId == document.objectId, !Task.isCancelled else { return }
            isNotEmpty = hasContent(document: document)
            updateCurrentDraftIndicator()
        }
    }

    private func hasContent(document: any BaseDocumentProtocol) -> Bool {
        if document.details?.name.isNotEmpty == true || document.details?.description.isNotEmpty == true { return true }
        return copyableBlocks(document: document).contains { info in
            if case let .text(text) = info.content { return text.text.isNotEmpty }
            return true
        }
    }

    private func subscribeOnSyncStatus(document: any BaseDocumentProtocol) async {
        for await _ in document.subscibeFor(update: [.syncStatus]).values {
            guard self.document?.objectId == document.objectId, !Task.isCancelled else { return }
            guard let status = document.syncStatus else { continue }
            syncStatusData = SyncStatusData(
                status: status,
                networkId: accountManager.account.info.networkId,
                isHidden: false
            )
        }
    }

    func openDraft(spaceId: String) async {
        let generation = beginDraftOperation()
        // Name the destination while it loads instead of showing an empty chip
        if editorData == nil { spaceView = findSpaceView(spaceId: spaceId) }
        do {
            await cleanupTasks[spaceId]?.value
            let details = try await quickCaptureService.obtainDraft(spaceId: spaceId)
            guard isCurrentDraftOperation(generation) else { return }
            let previousDocument = document
            let canCleanUpPrevious = !hasTypedThisSession
            setupDraft(details: details, spaceId: spaceId)
            if canCleanUpPrevious, let previousDocument, previousDocument.objectId != details.id {
                scheduleEmptyDraftCleanup(document: previousDocument)
            }
        } catch {
            guard isCurrentDraftOperation(generation) else { return }
            toastBarData = ToastBarData(error.localizedDescription, type: .failure)
            draftLoadFailed = editorData == nil
        }
    }

    private func setupDraft(details: ObjectDetails, spaceId: String) {
        resetDraftState()
        spaceView = findSpaceView(spaceId: spaceId)
        document = openDocumentProvider.document(objectId: details.id, spaceId: spaceId)
        // First guess from the search details; the content subscription refines it
        // once the document is open
        isNotEmpty = details.name.isNotEmpty || details.snippet.isNotEmpty
        updateCurrentDraftIndicator()
        // EditorPageObject directly, without EditorCoordinatorView/SpaceLoadingContainerView:
        // activating the space here would make SpaceHubCoordinator navigate under the sheet
        editorData = EditorPageObject(
            objectId: details.id,
            spaceId: spaceId,
            // Clearance for the sheet's own glass bar rather than for a navigation bar
            // the editor never draws here
            usecase: .sheet,
            quickCapture: true,
            // Drafts carry no cover or icon, so without the hint the placeholder would
            // shimmer a full-height cover and collapse the moment the document opens
            headerHint: ObjectHeaderExpectedLayout(details: details)
        )
    }

    private func scheduleEmptyDraftCleanup(document: any BaseDocumentProtocol) {
        cleanupTasks[document.spaceId] = Task {
            await deleteDraftIfEmpty(document: document)
        }
    }

    private func deleteDraftIfEmpty(document: any BaseDocumentProtocol) async {
        guard !hasContent(document: document) else { return }
        do {
            if try await quickCaptureService.deleteDraftIfEmpty(objectId: document.objectId, spaceId: document.spaceId) {
                draftSpaceIds.remove(document.spaceId)
            }
        } catch is CancellationError {
            return
        } catch {
            anytypeAssertionFailure("Unable to clean up an empty quick capture draft", info: ["error": error.localizedDescription])
        }
    }

    private func findSpaceView(spaceId: String) -> SpaceView? {
        participantSpacesStorage.activeParticipantSpaces
            .first { $0.spaceView.targetSpaceId == spaceId }?.spaceView
    }

    private func resetDraftState() {
        inputObserver.stopObserving()
        hasTypedThisSession = false
        editorData = nil
        document = nil
        isNotEmpty = false
        syncStatusData = nil
    }

    private func finishEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if let document { isNotEmpty = hasContent(document: document) }
    }

    private func updateCurrentDraftIndicator() {
        guard let spaceId = spaceView?.targetSpaceId else { return }
        if isNotEmpty && !hasPublished { draftSpaceIds.insert(spaceId) }
    }

    private func handleOpenObject(data: ScreenData) {
        guard let editorScreenData = data.editorScreenData, let objectId = editorScreenData.objectId else { return }
        // The draft survives dismissal, so navigation away loses nothing
        appActionStorage.action = .deepLink(.object(objectId: objectId, spaceId: editorScreenData.spaceId), .internal)
        dismiss?()
    }
}

// Settings menu output - only the actions the trimmed quick capture menu can trigger
extension QuickCaptureCoordinatorViewModel: ObjectSettingsCoordinatorOutput {
    func closeEditor() { }
    func showEditorScreen(data: ScreenData) {
        handleOpenObject(data: data)
    }
    func didCreateLinkToItself(selfName: String, data: ScreenData) { }
    func didCreateTemplate(templateId: String) { }
    func didTapUseTemplateAsDefault(templateId: String) { }
    func didUndoRedo() {
        undoRedoObjectId = editorData?.objectId.identifiable
    }
    func versionRestored(_ text: String) { }
}

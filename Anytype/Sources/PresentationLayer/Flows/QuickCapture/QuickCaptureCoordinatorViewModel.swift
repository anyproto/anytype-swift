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
    @ObservationIgnored
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    // MARK: - State

    var spaceView: SpaceView?
    var editorData: EditorPageObject?
    var isNotEmpty = false
    var showSpacePicker = false
    var showClearDraftConfirmation = false
    var toastBarData: ToastBarData?
    var syncStatusData: SyncStatusData?
    var syncStatusSpaceId: StringIdentifiable?
    var undoRedoObjectId: StringIdentifiable?

    @ObservationIgnored
    var dismiss: DismissAction?
    @ObservationIgnored
    private let onCreated: (QuickCaptureCreatedBanner) -> Void

    init(onCreated: @escaping (QuickCaptureCreatedBanner) -> Void) {
        self.onCreated = onCreated
    }
    @ObservationIgnored
    private var document: (any BaseDocumentProtocol)?

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
        guard editorData.isNil else { return }
        guard let targetSpace = sortedEditableSpaces.first else {
            dismiss?()
            return
        }
        await openDraft(spaceId: targetSpace.targetSpaceId)
    }

    func subscribeOnDraft() async {
        guard let document else { return }
        async let detailsSub: () = subscribeOnDetails(document: document)
        async let syncSub: () = subscribeOnSyncStatus(document: document)
        _ = await (detailsSub, syncSub)
    }

    func onTapSyncStatus() {
        guard let spaceId = spaceView?.targetSpaceId else { return }
        syncStatusSpaceId = spaceId.identifiable
    }

    // MARK: - Actions

    func onTapSend() {
        guard isNotEmpty, let spaceView, let document else { return }
        let spaceId = spaceView.targetSpaceId
        let objectId = document.objectId
        let analyticsType = document.details?.analyticsType ?? .custom
        let spaceName = spaceView.title
        let typeName = document.details?.objectType.displayName ?? Loc.PasteMenu.object
        Task {
            do {
                try await quickCaptureService.commitDraft(spaceId: spaceId)
            } catch {
                toastBarData = ToastBarData(error.localizedDescription, type: .failure)
                return
            }
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
        showClearDraftConfirmation = true
    }

    func onConfirmClearDraft() {
        guard let spaceId = spaceView?.targetSpaceId else { return }
        Task {
            resetDraftState()
            try? await quickCaptureService.clearDraft(spaceId: spaceId)
            await openDraft(spaceId: spaceId)
        }
    }

    func onTapSpaceChip() {
        showSpacePicker = true
    }

    func onSelectSpace(_ selected: SpaceView) {
        showSpacePicker = false
        guard let currentSpaceId = spaceView?.targetSpaceId, selected.targetSpaceId != currentSpaceId else { return }
        let moveContent = isNotEmpty
        Task {
            resetDraftState()
            do {
                if moveContent {
                    let details = try await quickCaptureService.moveDraft(from: currentSpaceId, to: selected.targetSpaceId)
                    setupDraft(details: details, spaceId: selected.targetSpaceId)
                } else {
                    await openDraft(spaceId: selected.targetSpaceId)
                }
            } catch {
                toastBarData = ToastBarData(error.localizedDescription, type: .failure)
                await openDraft(spaceId: selected.targetSpaceId)
            }
        }
    }

    // MARK: - Private

    private func subscribeOnDetails(document: any BaseDocumentProtocol) async {
        for await details in document.detailsPublisher.values {
            isNotEmpty = !details.internalFlagsValue.contains(.editorDeleteEmpty)
        }
    }

    private func subscribeOnSyncStatus(document: any BaseDocumentProtocol) async {
        for await _ in document.subscibeFor(update: [.syncStatus]).values {
            guard let status = document.syncStatus else { continue }
            syncStatusData = SyncStatusData(
                status: status,
                networkId: accountManager.account.info.networkId,
                isHidden: false
            )
        }
    }

    private func openDraft(spaceId: String) async {
        resetDraftState()
        do {
            let draft = try await quickCaptureService.obtainDraft(spaceId: spaceId)
            setupDraft(details: draft.details, spaceId: spaceId)
        } catch {
            toastBarData = ToastBarData(error.localizedDescription, type: .failure)
            dismiss?()
        }
    }

    private func setupDraft(details: ObjectDetails, spaceId: String) {
        spaceView = participantSpacesStorage.activeParticipantSpaces
            .first { $0.spaceView.targetSpaceId == spaceId }?.spaceView
        document = openDocumentProvider.document(objectId: details.id, spaceId: spaceId)
        isNotEmpty = !details.internalFlagsValue.contains(.editorDeleteEmpty)
        // EditorPageObject directly, without EditorCoordinatorView/SpaceLoadingContainerView:
        // activating the space here would make SpaceHubCoordinator navigate under the sheet
        editorData = EditorPageObject(objectId: details.id, spaceId: spaceId, quickCapture: true)
    }

    private func resetDraftState() {
        editorData = nil
        document = nil
        isNotEmpty = false
        syncStatusData = nil
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

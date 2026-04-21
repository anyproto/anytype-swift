import Foundation
import Services
import UIKit
import FloatingPanel
import SwiftUI
import AnytypeCore

enum ObjectSettingsAction {
    case cover(ObjectCoverPickerAction)
    case icon(ObjectIconPickerAction)
}

@MainActor
protocol ObjectSettingsModelOutput: AnyObject, ObjectHeaderRouterProtocol, ObjectHeaderModuleOutput {
    func undoRedoAction(objectId: String)
    func relationsAction(document: some BaseDocumentProtocol)
    func showVersionHistory(document: some BaseDocumentProtocol)
    func showPublising(document: some BaseDocumentProtocol)
    func openPageAction(screenData: ScreenData)
    func linkToAction(document: some BaseDocumentProtocol, onSelect: @escaping (String) -> ())
    func closeEditorAction()
    func didCreateLinkToItself(selfName: String, data: ScreenData)
    func didCreateTemplate(templateId: String)
    func didTapUseTemplateAsDefault(templateId: String)
    func showInviteMembers(spaceId: String)
    func showEditInfo(document: some BaseDocumentProtocol)
}

@MainActor
@Observable
final class ObjectSettingsViewModel {

    // MARK: - Settings Dependencies

    @Injected(\.openedDocumentProvider) @ObservationIgnored
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    @Injected(\.propertiesService) @ObservationIgnored
    private var propertiesService: any PropertiesServiceProtocol
    @Injected(\.objectSettingsBuilder) @ObservationIgnored
    private var settingsBuilder: any ObjectSettingsBuilderProtocol
    @Injected(\.objectSettingsConflictManager) @ObservationIgnored
    private var conflictManager: any ObjectSettingsPrimitivesConflictManagerProtocol

    // MARK: - Actions Dependencies

    @Injected(\.objectActionsService) @ObservationIgnored
    private var service: any ObjectActionsServiceProtocol
    @Injected(\.blockService) @ObservationIgnored
    private var blockService: any BlockServiceProtocol
    @Injected(\.templatesService) @ObservationIgnored
    private var templatesService: any TemplatesServiceProtocol
    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.channelPinsService) @ObservationIgnored
    private var channelPinsService: any ChannelPinsServiceProtocol
    @Injected(\.personalFavoritesService) @ObservationIgnored
    private var personalFavoritesService: any PersonalFavoritesServiceProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.universalLinkParser) @ObservationIgnored
    private var universalLinkParser: any UniversalLinkParserProtocol
    @Injected(\.workspaceService) @ObservationIgnored
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private weak var output: (any ObjectSettingsModelOutput)?

    @ObservationIgnored
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()

    @ObservationIgnored
    private lazy var widgetObject: (any BaseDocumentProtocol)? = {
        guard let info = workspaceStorage.spaceInfo(spaceId: spaceId) else {
            anytypeAssertionFailure("info not found")
            return nil
        }
        return openDocumentsProvider.document(objectId: info.widgetsId, spaceId: spaceId)
    }()

    // Per-user personal widgets document (IOS-5864). Opened lazily so flag-off
    // behaviour stays byte-identical. `isFavorited` is read from this document's
    // widget tree via the `BaseDocumentProtocol+Favorites` helper.
    //
    // Uses the per-space `AccountInfo` from `workspaceStorage` (same pattern as
    // `widgetObject` above) rather than the global `accountManager.account.info`:
    // (1) personal widgets are per-space, so the encoded id must reflect the
    // current space — using the global signup-space id would derive the wrong
    // virtual document in shared workspaces; (2) `accountManager.account.info`
    // can race app launch with `AccountData.empty`, which would silently ship
    // `_personalWidgets_` to MW.
    @ObservationIgnored
    private lazy var personalWidgetsObject: (any BaseDocumentProtocol)? = {
        guard FeatureFlags.personalFavorites else { return nil }
        guard let info = workspaceStorage.spaceInfo(spaceId: spaceId) else {
            anytypeAssertionFailure("info not found for personal widgets")
            return nil
        }
        return openDocumentsProvider.document(
            objectId: info.personalWidgetsId,
            spaceId: spaceId
        )
    }()

    @ObservationIgnored
    let objectId: String
    @ObservationIgnored
    let spaceId: String

    // MARK: - Settings State

    var settings: [ObjectSetting] = []
    var showConflictAlert = false
    var isChat = false
    let spaceUxType: SpaceUxType?
    let spaceType: SpaceType?

    // MARK: - Actions State

    var objectActions: [ObjectAction] = []
    // Mirrors `ParticipantSpaceViewData.canManageChannelPins` — today synonymous with
    // `isOwner`, but modelled as its own predicate so a future Admin role widens in
    // one spot. Used by `.pin` gating in `buildActions`. Kept separate from
    // `isSpaceOwner` so the two concepts do not collapse.
    private var canManageChannelPins: Bool = false
    // Real ownership check — drives `.inviteMembers` gating. Reads
    // `participantSpaceView.isOwner` directly so it stays decoupled from channel-pin
    // management semantics above.
    private var isSpaceOwner: Bool = false
    private var chatNotificationMode: SpacePushNotificationsMode?
    var toastData: ToastBarData?
    var dismiss = false
    var showDeleteChatConfirmation = false

    init(
        objectId: String,
        spaceId: String,
        output: some ObjectSettingsModelOutput
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output

        let spaceView = Container.shared.spaceViewsStorage().spaceView(spaceId: spaceId)
        spaceUxType = spaceView?.uxType
        spaceType = spaceView?.spaceType
    }

    // MARK: - Subscriptions

    func startDocumentTask() async {
        async let documentSub: () = startDocumentSubscription()
        async let widgetSub: () = startWidgetDocSubscription(widgetObject)
        async let personalWidgetSub: () = startWidgetDocSubscription(personalWidgetsObject)
        async let participantSub: () = startParticipantSpaceViewSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        _ = await (documentSub, widgetSub, personalWidgetSub, participantSub, spaceViewSub)
    }

    private func startDocumentSubscription() async {
        for await _ in document.syncPublisher.receiveOnMain().values {
            updateSettings()
            updateActions()
        }
    }

    private func startWidgetDocSubscription(_ doc: (any BaseDocumentProtocol)?) async {
        guard let doc else { return }
        for await _ in doc.syncPublisher.values {
            updateActions()
        }
    }

    private func startParticipantSpaceViewSubscription() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            canManageChannelPins = FeatureFlags.personalFavorites
                ? participantSpaceView.canManageChannelPins
                : true
            isSpaceOwner = participantSpaceView.isOwner
            updateActions()
        }
    }

    private func startSpaceViewSubscription() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            chatNotificationMode = spaceView.effectiveNotificationMode(for: objectId)
            updateSettings()
        }
    }

    private func updateSettings() {
        if let details = document.details {
            if FeatureFlags.createChannelFlow {
                settings = settingsBuilder.build(
                    details: details,
                    permissions: document.permissions,
                    spaceType: spaceType,
                    chatNotificationMode: chatNotificationMode
                )
            } else {
                settings = settingsBuilder.build(
                    details: details,
                    permissions: document.permissions,
                    spaceUxType: spaceUxType,
                    chatNotificationMode: chatNotificationMode
                )
            }
            isChat = details.resolvedLayoutValue.isChat
        }
    }

    private func updateActions() {
        guard let details = document.details else {
            objectActions = []
            return
        }

        let isPinnedToWidgets = widgetObject?.widgetBlockIdFor(targetObjectId: objectId).isNotNil ?? false
        let isFavorited = personalWidgetsObject?.isInMyFavorites(objectId: objectId) ?? false

        if FeatureFlags.createChannelFlow {
            objectActions = ObjectAction.buildActions(
                details: details,
                isLocked: document.isLocked,
                isPinnedToWidgets: isPinnedToWidgets,
                isFavorited: isFavorited,
                canManageChannelPins: canManageChannelPins,
                permissions: document.permissions,
                spaceType: spaceType,
                isSpaceOwner: isSpaceOwner
            )
        } else {
            objectActions = ObjectAction.buildActions(
                details: details,
                isLocked: document.isLocked,
                isPinnedToWidgets: isPinnedToWidgets,
                isFavorited: isFavorited,
                canManageChannelPins: canManageChannelPins,
                permissions: document.permissions,
                spaceUxType: spaceUxType,
                isSpaceOwner: isSpaceOwner
            )
        }
    }

    func onTapIconPicker() {
        output?.showIconPicker(document: document)
    }
    
    func onTapCoverPicker() {
        output?.showCoverPicker(document: document)
    }
    
    func onTapRelations() {
        output?.relationsAction(document: document)
    }
    
    func onTapHistory() {
        output?.showVersionHistory(document: document)
    }
    
    func onTapDescription() async throws {
        guard let details = document.details else { return }
        
        let descriptionIsOn = details.featuredRelations.contains(where: { $0 == BundledPropertyKey.description.rawValue })
        try await propertiesService.toggleDescription(objectId: document.objectId, isOn: !descriptionIsOn)
    }
    
    func onTapPrefillName() async throws {
        guard let details = document.details else { return }
        let newValue = details.isTemplateNamePrefilled ? 0 : 1
        try await service.updateBundledDetails(
            contextID: document.objectId,
            details: [.templateNamePrefillType(newValue)]
        )
    }

    func onTapResolveConflict() {
        showConflictAlert.toggle()
    }
    
    func onTapResolveConflictApprove() async throws {
        guard let details = document.details else { return }
        try await conflictManager.resolveConflicts(details: details)
        AnytypeAnalytics.instance().logResetToTypeDefault()
    }
    
    func onTapPublishing() {
        if let details = document.details {
            AnytypeAnalytics.instance().logClickShareObject(objectType: details.objectType.analyticsType)
        }
        output?.showPublising(document: document)
    }

    func changeNotificationMode(_ mode: SpacePushNotificationsMode) async throws {
        try await workspaceService.pushNotificationSetChatMode(
            spaceId: spaceId,
            chatIds: [objectId],
            mode: mode
        )
        AnytypeAnalytics.instance().logChangeMessageNotificationState(
            type: mode.analyticsValue,
            route: .chatSettings,
            uxType: .chat
        )
        dismiss.toggle()
    }

    // MARK: - Object Actions

    func changeArchiveState() async throws {
        guard let details = document.details else { return }

        let isArchived = !details.isArchived
        AnytypeAnalytics.instance().logMoveToBin(isArchived)
        try await service.setArchive(objectIds: [objectId], isArchived)
        if isArchived {
            dismiss.toggle()
            output?.closeEditorAction()
        }
    }

    func changePinState() async throws {
        // TODO: IOS-5864 No dedicated pin/unpin analytics event exists today.
        // Add `logPinObject` / `logUnpinObject` (or a unified `logChangePinState(pinned:)`)
        // once product confirms the event shape. Reorder already has `logReorderWidget`.
        guard let widgetObject else {
            anytypeAssertionFailure("Widget object not found")
            return
        }

        guard let details = document.details else {
            anytypeAssertionFailure("Details object not found")
            return
        }

        // Per-object-type layout: a Set pins as `.view` with limit 6, a regular page
        // pins as `.link` with limit 0, etc. Preserved from the pre-IOS-5864 shape so
        // Object Settings pin semantics stay richer than the widget-menu flow (which
        // always uses `.link`/`0`).
        guard let layout = details.availableWidgetLayout.first else {
            anytypeAssertionFailure("Default layout not found")
            return
        }

        let wasPinned = widgetObject.widgetBlockIdFor(targetObjectId: details.id).isNotNil

        try await channelPinsService.toggle(
            objectId: details.id,
            channelWidgetsObject: widgetObject,
            layout: layout,
            limit: layout.limits.first ?? 0
        )

        toastData = ToastBarData(wasPinned ? Loc.unpinned : Loc.pinned)
        dismiss.toggle()
    }

    func changeFavoriteState() async throws {
        // TODO: IOS-5864 No dedicated favorite/unfavorite analytics event exists today.
        // Add `logFavoriteObject` / `logUnfavoriteObject` (or a unified
        // `logChangeFavoriteState(favorited:)`) once product confirms the event shape.
        // Reorder of My Favorites is already covered via `logReorderWidget(source: .personalFavorites)`.
        guard let details = document.details else {
            anytypeAssertionFailure("Details object not found")
            return
        }
        guard let personalWidgetsObject else {
            anytypeAssertionFailure("personalWidgetsObject not found for favorite toggle")
            return
        }
        let wasFavorited = personalWidgetsObject.isInMyFavorites(objectId: details.id)
        try await personalFavoritesService.toggle(objectId: details.id, personalWidgetsObject: personalWidgetsObject)
        toastData = ToastBarData(wasFavorited ? Loc.unfavorited : Loc.favorited)
        dismiss.toggle()
    }

    func changeLockState() async throws {
        let isCurrentlyLocked = document.isLocked
        AnytypeAnalytics.instance().logLockPage(!isCurrentlyLocked)
        try await service.setLocked(!isCurrentlyLocked, objectId: objectId)
        toastData = ToastBarData(isCurrentlyLocked ? Loc.unlocked : Loc.locked)
        dismiss.toggle()
    }

    func duplicateAction() async throws {
        guard let details = document.details else { return }

        AnytypeAnalytics.instance().logDuplicateObject(count: 1, objectType: details.objectType.analyticsType)

        let duplicatedId = try await service.duplicate(objectId: objectId)

        let newDetails = ObjectDetails(id: duplicatedId, values: details.values)
        dismiss.toggle()
        output?.openPageAction(screenData: newDetails.screenData())
    }

    func linkItselfAction() {
        guard let currentObjectId = document.details?.id else { return }
        let spaceId = document.spaceId
        let onObjectSelection: (String) -> Void = { [weak self] objectId in
            self?.onObjectSelection(objectId: objectId, spaceId: spaceId, currentObjectId: currentObjectId)
        }

        output?.linkToAction(document: document, onSelect: onObjectSelection)
    }

    func makeAsTemplate() async throws {
        guard let details = document.details else { return }

        let templateId = try await templatesService.createTemplateFromObject(objectId: details.id)
        AnytypeAnalytics.instance().logTemplateCreate(objectType: details.objectType.analyticsType)
        output?.didCreateTemplate(templateId: templateId)
    }

    func templateToggleDefaultState() async throws {
        guard let details = document.details,
        let targetObjectType = details.targetObjectTypeValue else { return }

        let isCurrentlyDefault = targetObjectType.defaultTemplateId == details.id
        let newTemplateId = isCurrentlyDefault ? "" : details.id

        output?.didTapUseTemplateAsDefault(templateId: newTemplateId)
    }

    func deleteAction() async throws {
        guard let details = document.details else { return }

        AnytypeAnalytics.instance().logDeletion(count: 1, route: .bin)
        try await service.delete(objectIds: [details.id])
        dismiss.toggle()
        output?.closeEditorAction()
    }

    func copyLinkAction() async throws {
        guard let details = document.details else { return }

        let invite = try? await workspaceService.getCurrentInvite(spaceId: details.spaceId)
        let link = universalLinkParser.createUrl(link: .object(objectId: details.id, spaceId: details.spaceId, cid: invite?.cid, key: invite?.fileKey))

        UIPasteboard.general.string = link?.absoluteString
        toastData = ToastBarData(Loc.copied)
        dismiss.toggle()
    }

    func undoRedoAction() {
        output?.undoRedoAction(objectId: objectId)
    }

    func inviteMembersAction() {
        output?.showInviteMembers(spaceId: spaceId)
        dismiss.toggle()
    }

    func editInfoAction() {
        output?.showEditInfo(document: document)
    }

    // MARK: - Private Action Helpers

    private func onObjectSelection(objectId: String, spaceId: String, currentObjectId: String) {
        Task { @MainActor in
            let targetDocument = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
            try? await targetDocument.open()
            guard let id = targetDocument.children.last?.id,
                  let details = targetDocument.details else { return }

            if details.isCollection {
                try await service.addObjectsToCollection(
                    contextId: objectId,
                    objectIds: [currentObjectId]
                )
                onLinkItselfToObjectHandler(data: details.screenData())
                AnytypeAnalytics.instance().logLinkToObject(type: .collection)
            } else {
                let info = BlockInformation.emptyLink(targetId: currentObjectId)
                AnytypeAnalytics.instance().logCreateBlock(type: info.content.type, spaceId: details.spaceId)
                let _ = try await blockService.add(
                    contextId: objectId,
                    targetId: id,
                    info: info,
                    position: .bottom
                )
                onLinkItselfToObjectHandler(data: details.screenData())
                AnytypeAnalytics.instance().logLinkToObject(type: .object)
            }
        }
    }

    private func onLinkItselfToObjectHandler(data: ScreenData) {
        guard let documentName = document.details?.name else { return }
        output?.didCreateLinkToItself(selfName: documentName, data: data)
    }
}

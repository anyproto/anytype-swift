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
    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
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
    @Injected(\.accountManager) @ObservationIgnored
    private var accountManager: any AccountManagerProtocol

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
    @ObservationIgnored
    private lazy var personalWidgetsObject: (any BaseDocumentProtocol)? = {
        guard FeatureFlags.personalFavorites else { return nil }
        return openDocumentsProvider.document(
            objectId: accountManager.account.info.personalWidgetsId,
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
        async let widgetSub: () = startWidgetObjectSubscription()
        async let personalWidgetSub: () = startPersonalWidgetsObjectSubscription()
        async let ownerSub: () = startOwnerStatusSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        _ = await (documentSub, widgetSub, personalWidgetSub, ownerSub, spaceViewSub)
    }

    private func startDocumentSubscription() async {
        for await _ in document.syncPublisher.receiveOnMain().values {
            updateSettings()
            updateActions()
        }
    }

    private func startWidgetObjectSubscription() async {
        guard let widgetObject else { return }
        for await _ in widgetObject.syncPublisher.values {
            updateActions()
        }
    }

    private func startPersonalWidgetsObjectSubscription() async {
        guard let personalWidgetsObject else { return }
        for await _ in personalWidgetsObject.syncPublisher.values {
            updateActions()
        }
    }

    private func startOwnerStatusSubscription() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            isSpaceOwner = participantSpaceView.participant?.permission == .owner
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

    // Channel pins are Owner-only on iOS today. The middleware has no Admin role
    // (verified 2026-04-17 in plan Context). When/if MW adds Admin, widen this
    // single predicate — all call sites pass through it.
    private var canManageChannelPins: Bool {
        // When the feature flag is off, fall back to the legacy behaviour where
        // every canCreateWidget-eligible object can be pinned by anyone who passes
        // permission checks. The split (Owner-only channel pin + everyone Favorite)
        // only activates when the flag is on.
        guard FeatureFlags.personalFavorites else { return true }
        return isSpaceOwner
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

    func changePinState(_ pinned: Bool) async throws {
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

        if pinned {

            guard let widgetBlockId = widgetObject.widgetBlockIdFor(targetObjectId: details.id) else {
                anytypeAssertionFailure("Block not found")
                return
            }

            try await blockWidgetService.removeWidgetBlock(contextId: widgetObject.objectId, widgetBlockId: widgetBlockId)

        } else {
            guard let layout = details.availableWidgetLayout.first else {
                anytypeAssertionFailure("Default layout not found")
                return
            }

            let first = widgetObject.children.first

            try await blockWidgetService.createWidgetBlock(
                contextId: widgetObject.objectId,
                sourceId: details.id,
                layout: layout,
                limit: layout.limits.first ?? 0,
                position: first.map { .above(widgetId: $0.id) } ?? .end
            )
        }
        toastData = ToastBarData(pinned ? Loc.unpinned : Loc.pinned)
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
        let accountInfo = accountManager.account.info
        let wasFavorited = personalWidgetsObject?.isInMyFavorites(objectId: details.id) ?? false
        try await personalFavoritesService.toggle(objectId: details.id, accountInfo: accountInfo)
        toastData = ToastBarData(wasFavorited ? Loc.unfavorite : Loc.favorite)
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

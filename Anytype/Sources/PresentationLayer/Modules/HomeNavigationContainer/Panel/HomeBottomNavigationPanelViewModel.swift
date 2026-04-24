import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
@Observable
final class HomeBottomNavigationPanelViewModel {

    private enum Constants {
        static let priorityTypesUniqueKeys: [ObjectTypeUniqueKey] = [.page, .note, .task]
    }

    // MARK: - Private properties
    @ObservationIgnored
    private let info: AccountInfo

    @ObservationIgnored @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @ObservationIgnored @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored @Injected(\.experimentalFeaturesStorage)
    private var experimentalFeaturesStorage: any ExperimentalFeaturesStorageProtocol
    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol

    @ObservationIgnored
    private weak var output: (any HomeBottomNavigationPanelModuleOutput)?

    @ObservationIgnored
    private var currentData: AnyHashable?
    @ObservationIgnored
    private var participantSpaceView: ParticipantSpaceViewData?
    @ObservationIgnored
    private var detailsSubscriptionTask: Task<Void, Never>?
    @ObservationIgnored
    private let messageCountObserver: any DiscussionMessageCountObserverProtocol = DiscussionMessageCountObserver()
    @ObservationIgnored
    private var currentDiscussionId: String?

    // MARK: - Public properties

    var showDiscussButton: Bool = false
    var canCreateObject: Bool = false
    var commentsCount: Int = 0
    var pageObjectType: ObjectType?
    var noteObjectType: ObjectType?
    var taskObjectType: ObjectType?
    var otherObjectTypes: [ObjectType] = []
    var newObjectPlusMenu: Bool = false

    var spaceId: String { info.accountSpaceId }

    init(
        info: AccountInfo,
        output: (any HomeBottomNavigationPanelModuleOutput)?
    ) {
        self.info = info
        self.output = output
    }
    
    func onTapNewObject() {
        handleCreateObject()
    }

    func onLongPressNewObject(details: ObjectDetails) {
        output?.onCreateObjectSelected(screenData: details.screenData())
    }

    func onTapSearch() {
        output?.onSearchSelected()
    }
    
    func onTapDiscuss() {
        guard let editorData = currentData as? EditorScreenData,
              let objectId = editorData.objectId else {
            anytypeAssertionFailure("Discuss button tapped but no editor data available")
            return
        }
        let document = documentsProvider.document(objectId: objectId, spaceId: editorData.spaceId)
        let objectName = document.details?.name ?? ""
        let discussionId = document.details?.discussionId
        let screenData = ScreenData.discussion(DiscussionCoordinatorData(
            discussionId: discussionId?.isEmpty == false ? discussionId : nil,
            objectId: objectId,
            objectName: objectName,
            spaceId: editorData.spaceId
        ))
        output?.onCreateObjectSelected(screenData: screenData)
    }

    func startSubscriptions() async {
        async let participantSub: () = participantSubscription()
        async let typesSub: () = typesSubscription()
        async let featuresSub: () = featuresSubscription()
        async let messageCountSub: () = subscribeOnMessageCount()

        _ = await (participantSub, typesSub, featuresSub, messageCountSub)
    }
    
    func updateVisibleScreen(data: AnyHashable) {
        currentData = data
        updateState()
        subscribeToDetailsChanges(from: data)
    }

    func onTapCreateObject(type: ObjectType) {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(objectType: type.analyticsType, route: clickAddMenuAnalyticsRoute())

        if type.isChatType {
            let screenData = ScreenData.alert(.chatCreate(ChatCreateScreenData(
                spaceId: info.accountSpaceId,
                analyticsRoute: .navigation
            )))
            output?.onCreateObjectSelected(screenData: screenData)
            return
        }

        if type.isBookmarkType {
            let screenData = ScreenData.alert(.bookmarkCreate(BookmarkCreateScreenData(
                spaceId: info.accountSpaceId,
                analyticsRoute: .navigation
            )))
            output?.onCreateObjectSelected(screenData: screenData)
            return
        }

        Task { @MainActor in
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: true,
                shouldSelectTemplate: true,
                spaceId: info.accountSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .navigation)
            
            try? await objectActionsService.updateBundledDetails(contextID: type.id, details: [ .lastUsedDate(Date.now)])
            
            output?.onCreateObjectSelected(screenData: details.screenData())
        }
    }
    
    func onAddMediaSelected() {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(type: .photo, route: clickAddMenuAnalyticsRoute())
        output?.onAddMediaSelected(spaceId: info.accountSpaceId)
    }
    
    func onCameraSelected() {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(type: .camera, route: clickAddMenuAnalyticsRoute())
        output?.onCameraSelected(spaceId: info.accountSpaceId)
    }
    
    func onAddFilesSelected() {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(type: .file, route: clickAddMenuAnalyticsRoute())
        output?.onAddFilesSelected(spaceId: info.accountSpaceId)
    }
    
    // MARK: - Private

    private func subscribeToDetailsChanges(from data: AnyHashable) {
        detailsSubscriptionTask?.cancel()
        detailsSubscriptionTask = nil
        guard let editorData = data as? EditorScreenData,
              let objectId = editorData.objectId else { return }
        let document = documentsProvider.document(objectId: objectId, spaceId: editorData.spaceId)
        detailsSubscriptionTask = Task { [weak self] in
            for await _ in document.detailsPublisher.values {
                guard !Task.isCancelled else { return }
                self?.updateState()
            }
        }
    }

    private func participantSubscription() async {
        for await data in participantSpacesStorage.participantSpaceViewPublisher(spaceId: info.accountSpaceId).values {
            participantSpaceView = data
            updateState()
        }
    }
    
    private func typesSubscription() async {
        for await types in objectTypeProvider.objectTypesPublisher(spaceId: info.accountSpaceId).values {
            let supportedLayouts: [DetailsLayout]
            if FeatureFlags.createChannelFlow {
                let spaceType = spaceViewsStorage.spaceView(spaceId: info.accountSpaceId)?.spaceType
                supportedLayouts = DetailsLayout.supportedForCreation(spaceType: spaceType)
            } else {
                let spaceUxType = spaceViewsStorage.spaceView(spaceId: info.accountSpaceId)?.uxType
                supportedLayouts = DetailsLayout.supportedForCreation(spaceUxType: spaceUxType)
            }
            let types = types.filter { type in
                supportedLayouts.contains { $0 == type.recommendedLayout }
                && !type.isTemplateType
            }
            
            // priority object types
            pageObjectType = types.first { $0.uniqueKey == ObjectTypeUniqueKey.page }
            noteObjectType = types.first { $0.uniqueKey == ObjectTypeUniqueKey.note }
            taskObjectType = types.first { $0.uniqueKey == ObjectTypeUniqueKey.task }

            // other object types (excluding Image and File types as per requirements)
            otherObjectTypes = types
                .filter {
                    !Constants.priorityTypesUniqueKeys.contains($0.uniqueKey) &&
                    $0.uniqueKey != .image &&
                    $0.uniqueKey != .file
                }
        }
    }
    
    private func featuresSubscription() async {
        for await newObjectCreationMenu in experimentalFeaturesStorage.newObjectCreationMenuSequence {
            newObjectPlusMenu = newObjectCreationMenu
        }
    }
    
    private func updateState() {
        guard let participantSpaceView else { return }

        // Skip state update when navigating to discussion — panel will be hidden anyway,
        // and updating would flicker the discuss button to search during push animation.
        // Intentionally do NOT stop observing: popping back to the editor should show the
        // same count without a reload bounce.
        if currentData is DiscussionCoordinatorData { return }

        canCreateObject = participantSpaceView.permissions.canEdit
        guard let editorData = currentData as? EditorScreenData,
              let objectId = editorData.objectId else {
            showDiscussButton = false
            currentDiscussionId = nil
            commentsCount = 0
            Task { [messageCountObserver] in await messageCountObserver.stopObserving() }
            return
        }
        let document = documentsProvider.document(objectId: objectId, spaceId: editorData.spaceId)
        let discussionId = document.details?.discussionId
        let hasDiscussion = discussionId?.isNotEmpty == true
        showDiscussButton = FeatureFlags.discussionButton && (canCreateObject || hasDiscussion)

        if hasDiscussion, let discussionId {
            if currentDiscussionId != discussionId {
                currentDiscussionId = discussionId
                commentsCount = 0
                let spaceId = editorData.spaceId
                Task { [messageCountObserver] in
                    await messageCountObserver.startObserving(spaceId: spaceId, chatId: discussionId)
                }
            }
        } else {
            currentDiscussionId = nil
            commentsCount = 0
            Task { [messageCountObserver] in await messageCountObserver.stopObserving() }
        }
    }

    private func subscribeOnMessageCount() async {
        for await update in await messageCountObserver.messageCountStream {
            guard update.chatId == currentDiscussionId else { continue }
            commentsCount = update.count
        }
    }

    private func handleCreateObject() {
        Task { @MainActor in
            guard let details = try? await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: info.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .navigation)

            output?.onCreateObjectSelected(screenData: details.screenData())
        }
    }

    private func clickAddMenuAnalyticsRoute() -> ClickNavBarAddMenuRoute? {
        // Read before sending the event. This way we can keep track of which screens don't have a route.
        if let provider = currentData as? any HomeClinkNavBarAddMenuRouteProvider {
            return provider.clickNavBarAddMenuRoute
        }
        if let currentData {
            anytypeAssertionFailure("Home data without ClinkNavBarAddMenuRoute", info: ["type": "\(currentData)"])
        }
        return nil
    }
}

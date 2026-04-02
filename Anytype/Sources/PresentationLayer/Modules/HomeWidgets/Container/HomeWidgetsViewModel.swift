import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI
import AsyncAlgorithms

@MainActor
@Observable
final class HomeWidgetsViewModel {

    private enum Constants {
        static let pinnedSectionId = "HomePinnedSection"
        static let objectTypeSectionId = "HomeObjectTypeSection"
        static let unreadSectionId = "HomeUnreadSection"
    }
    
    // MARK: - DI

    let info: AccountInfo
    let widgetObject: any BaseDocumentProtocol

    @Injected(\.blockWidgetService) @ObservationIgnored
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionService: any ObjectActionsServiceProtocol
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let workspaceStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    @Injected(\.participantsStorage) @ObservationIgnored
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    @Injected(\.homeWidgetsRecentStateManager) @ObservationIgnored
    private var recentStateManager: any HomeWidgetsRecentStateManagerProtocol
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.expandedService) @ObservationIgnored
    private var expandedService: any ExpandedServiceProtocol
    @Injected(\.chatMessagesPreviewsStorage) @ObservationIgnored
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.objectTypesWithObjectsCreatedService) @ObservationIgnored
    private var objectTypesWithObjectsCreatedService: any ObjectTypesWithObjectsCreatedServiceProtocol
    @Injected(\.chatDetailsStorage) @ObservationIgnored
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?
    
    // MARK: - State
    
    var widgetBlocks: [BlockWidgetInfo] = []
    var objectTypeWidgets: [ObjectTypeWidgetInfo] = []
    var homeState: HomeWidgetsState = .readonly
    var widgetsDataLoaded: Bool = false
    var objectTypesDataLoaded: Bool = false
    var wallpaper: SpaceWallpaperType = .default
    var pinnedSectionIsExpanded: Bool = false
    var objectTypeSectionIsExpanded: Bool = false
    var canCreateObjectType: Bool = false
    var chatWidgetData: SpaceChatWidgetData?
    var unreadSectionIsExpanded: Bool = false
    var unreadChats: [UnreadChatWidgetData] = []
    private var supportsMultiChats: Bool = false

    var spaceId: String { info.accountSpaceId }

    var shouldShowUnreadSection: Bool {
        supportsMultiChats && unreadChats.isNotEmpty
    }

    var shouldHideChatBadges: Bool {
        shouldShowUnreadSection && unreadSectionIsExpanded
    }

    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
        self.widgetObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
        self.pinnedSectionIsExpanded = expandedService.isExpanded(id: Constants.pinnedSectionId, defaultValue: true)
        self.objectTypeSectionIsExpanded = expandedService.isExpanded(id: Constants.objectTypeSectionId, defaultValue: true)
        self.unreadSectionIsExpanded = expandedService.isExpanded(id: Constants.unreadSectionId, defaultValue: true)
    }

    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let participantTask: () = startParticipantTask()
        async let objectTypesTask: () = startObjectTypesTask()
        async let spaceViewTask: () = startSpaceViewTask()
        async let unreadChatsTask: () = startUnreadChatsTask()

        _ = await (widgetObjectSub, participantTask, objectTypesTask, spaceViewTask, unreadChatsTask)
    }

    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget()
    }

    func widgetsDropUpdate(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        widgetBlocks.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func widgetsDropFinish(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        AnytypeAnalytics.instance().logReorderWidget(source: from.data.source.analyticsSource)
        Task {
            try? await objectActionService.move(
                dashboadId: widgetObject.objectId,
                blockId: from.data.id,
                dropPositionblockId: to.data.id,
                position: to.index > from.index ? .bottom : .top
            )
        }
    }
    
    func onSpaceSelected() {
        output?.onSpaceSelected()
    }

    func onMembersSelected(spaceId: String, route: SettingsSpaceShareRoute) {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: route)
    }

    func onQrCodeSelected(url: URL) {
        output?.onSpaceChatShowQrCodeSelected(url: url)
    }

    func onCreateObjectType() {
        output?.onCreateObjectType()
    }
    
    func onTapPinnedHeader() {
        withAnimation {
            pinnedSectionIsExpanded = !pinnedSectionIsExpanded
        }
        expandedService.setState(id: Constants.pinnedSectionId, isExpanded: pinnedSectionIsExpanded)
    }
    
    func onTapObjectTypeHeader() {
        withAnimation {
            objectTypeSectionIsExpanded = !objectTypeSectionIsExpanded
        }
        expandedService.setState(id: Constants.objectTypeSectionId, isExpanded: objectTypeSectionIsExpanded)
    }

    func onTapUnreadHeader() {
        withAnimation {
            unreadSectionIsExpanded = !unreadSectionIsExpanded
        }
        expandedService.setState(id: Constants.unreadSectionId, isExpanded: unreadSectionIsExpanded)
    }

    // MARK: - Private
    
    private func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            widgetsDataLoaded = true
            
            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
            
            let newWidgetBlocks = blocks
                .compactMap { widgetObject.widgetInfo(block: $0) }
            
            guard widgetBlocks != newWidgetBlocks else { continue }
            
            widgetBlocks = newWidgetBlocks
        }
    }
    
    private func startParticipantTask() async {
        for await canEdit in accountParticipantStorage.canEditSequence(spaceId: info.accountSpaceId) {
            homeState = canEdit ? .readwrite : .readonly
            canCreateObjectType = canEdit
        }
    }
    
    private func startObjectTypesTask() async {
        let spaceId = spaceId
        let allowedLayouts: [DetailsLayout]
        if FeatureFlags.createChannelFlow {
            let spaceType = workspaceStorage.spaceView(spaceId: spaceId)?.spaceType
            allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceType: spaceType)
            await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceType: spaceType)
        } else {
            let spaceUxType = workspaceStorage.spaceView(spaceId: spaceId)?.uxType
            allowedLayouts = DetailsLayout.widgetTypeLayouts(spaceUxType: spaceUxType)
            await objectTypesWithObjectsCreatedService.startSubscription(spaceId: spaceId, spaceUxType: spaceUxType)
        }

        let typesPublisher = objectTypeProvider.objectTypesPublisher(spaceId: spaceId)
        let objectsCreatedPublisher = objectTypesWithObjectsCreatedService.typeIdsWithObjectsCreatedPublisher

        let stream = typesPublisher.combineLatest(objectsCreatedPublisher)
            .map { (types, typeIdsWithObjectsCreated) in
                types
                    .filter { ($0.recommendedLayout.map { allowedLayouts.contains($0) } ?? false) && !$0.isTemplateType }
                    .filter { typeIdsWithObjectsCreated.contains($0.id) }
                    .map { ObjectTypeWidgetInfo(objectTypeId: $0.id, spaceId: spaceId) }
            }
            .removeDuplicates()
            .values

        for await objectTypes in stream {
            objectTypesDataLoaded = true
            objectTypeWidgets = objectTypes
        }
    }

    private func startSpaceViewTask() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            chatWidgetData = spaceView.canShowChatWidget ? SpaceChatWidgetData(spaceId: spaceId, output: output) : nil
            supportsMultiChats = spaceView.uxType.supportsMultiChats
        }
    }

    private func startUnreadChatsTask() async {
        let spaceId = spaceId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        guard spaceView?.uxType.supportsMultiChats ?? false else { return }

        let previewsSequence = await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
        let chatsSequence = await chatDetailsStorage.allChatsSequence
        let spaceViewSequence = workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values

        for await (previews, chatDetails, currentSpaceView) in combineLatest(previewsSequence, chatsSequence, spaceViewSequence) {
            let newUnreadChats = previews
                .filter { preview in
                    guard preview.spaceId == spaceId else { return false }

                    if FeatureFlags.muteAndHide {
                        let mode = currentSpaceView.effectiveNotificationMode(for: preview.chatId)
                        if mode == .nothing {
                            guard preview.mentionCounter > 0 || preview.hasUnreadReactions else { return false }
                        }
                    }

                    guard preview.hasCounters else { return false }
                    guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }) else { return false }
                    return !chatDetail.isArchivedOrDeleted
                }
                .map { UnreadChatWidgetData(id: $0.chatId, spaceId: spaceId, output: output) }

            guard unreadChats != newUnreadChats else { continue }
            unreadChats = newUnreadChats
        }
    }
}

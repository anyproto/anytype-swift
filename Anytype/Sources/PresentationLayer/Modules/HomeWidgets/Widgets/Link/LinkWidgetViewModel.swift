import Foundation
import Services
import AnytypeCore
import Factory


@MainActor
@Observable
final class LinkWidgetViewModel {

    // MARK: - DI

    @ObservationIgnored
    private let widgetBlockId: String
    @ObservationIgnored
    private let widgetObject: any BaseDocumentProtocol
    @ObservationIgnored
    private weak var output: (any CommonWidgetModuleOutput)?

    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.widgetChatPreviewBuilder)
    private var chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol
    @ObservationIgnored
    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol
    @ObservationIgnored
    @Injected(\.parentObjectUnreadBadgeBuilder)
    private var parentBadgeBuilder: any ParentObjectUnreadBadgeBuilderProtocol

    // MARK: - State

    @ObservationIgnored
    private var linkedObjectDetails: ObjectDetails?
    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []
    @ObservationIgnored
    private var unreadDiscussionsBySpace: [String: SpaceDiscussionsUnreadInfo] = [:]

    private(set) var name = ""
    private(set) var icon: Icon?
    private(set) var badgeModel: MessagePreviewModel?
    private(set) var parentBadge: ParentObjectUnreadBadge?
    var dragId: String? { widgetBlockId }

    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.channelWidgetsObject
        self.output = data.output
    }
    
    func onHeaderTap() {
        guard let linkedObjectDetails else { return }
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(
            source: .object(type: linkedObjectDetails.analyticsType),
            createType: info.widgetCreateType
        )
        output?.onObjectSelected(screenData: linkedObjectDetails.screenData())
    }
    
    func startSubscriptions() async {
        async let detailsSub: () = startDetailsSubscriptions()
        async let chatPreviewsSub: () = startChatPreviewsSubscription()
        async let unreadDiscussionsSub: () = startUnreadDiscussionsSubscription()
        async let spaceViewsSub: () = startSpaceViewsSubscription()

        _ = await (detailsSub, chatPreviewsSub, unreadDiscussionsSub, spaceViewsSub)
    }

    // MARK: - Private

    private func startDetailsSubscriptions() async {
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            linkedObjectDetails = details
            name = details.pluralTitle
            icon = details.objectIconImage
            updateBadges()
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            updateBadges()
        }
    }

    private func startSpaceViewsSubscription() async {
        // Linked space id is dynamic; recompute badges on any space-view change. updateBadges()
        // guards on equality so unrelated emits become no-ops downstream.
        for await _ in spaceViewsStorage.allSpaceViewsPublisher.removeDuplicates().values {
            updateBadges()
        }
    }

    private func startUnreadDiscussionsSubscription() async {
        for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
            unreadDiscussionsBySpace = unreadBySpace
            updateBadges()
        }
    }

    private func updateBadges() {
        guard let linkedObjectDetails else {
            if badgeModel != nil { badgeModel = nil }
            if parentBadge != nil { parentBadge = nil }
            return
        }
        let spaceView = spaceViewsStorage.spaceView(spaceId: linkedObjectDetails.spaceId)

        let nextChatBadge = chatPreviews.first(where: { $0.chatId == linkedObjectDetails.id }).flatMap {
            chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
        }
        if badgeModel != nextChatBadge {
            badgeModel = nextChatBadge
        }

        let parent = unreadDiscussionsBySpace[linkedObjectDetails.spaceId]?
            .parents.first(where: { $0.id == linkedObjectDetails.id })
        let nextParentBadge = parent.map { parentBadgeBuilder.build(parent: $0, spaceView: spaceView) }
        if parentBadge != nextParentBadge {
            parentBadge = nextParentBadge
        }
    }
}

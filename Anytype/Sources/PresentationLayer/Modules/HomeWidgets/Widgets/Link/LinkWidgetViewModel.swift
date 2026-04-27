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

        _ = await (detailsSub, chatPreviewsSub, unreadDiscussionsSub)
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

    private func startUnreadDiscussionsSubscription() async {
        for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
            unreadDiscussionsBySpace = unreadBySpace
            updateBadges()
        }
    }

    private func updateBadges() {
        guard let linkedObjectDetails else {
            badgeModel = nil
            parentBadge = nil
            return
        }
        let spaceView = spaceViewsStorage.spaceView(spaceId: linkedObjectDetails.spaceId)

        badgeModel = chatPreviews.first(where: { $0.chatId == linkedObjectDetails.id }).flatMap {
            chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
        }

        let parent = unreadDiscussionsBySpace[linkedObjectDetails.spaceId]?
            .parents.first(where: { $0.id == linkedObjectDetails.id })
        parentBadge = parent.map { parentBadgeBuilder.build(parent: $0, spaceView: spaceView) }
    }
}

import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesRowViewModel {

    // MARK: - Construction context

    let widgetBlockId: String
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let menuViewModel: MyFavoritesRowContextMenuViewModel

    @ObservationIgnored
    private let onObjectSelected: (ObjectDetails) -> Void

    var objectId: String { details.id }

    // MARK: - DI

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
    private var details: ObjectDetails
    @ObservationIgnored
    private var chatPreview: ChatMessagePreview?
    @ObservationIgnored
    private var unreadParent: DiscussionUnreadParent?

    private(set) var title: String
    private(set) var icon: Icon?
    private(set) var badgeModel: MessagePreviewModel?
    private(set) var parentBadge: ParentObjectUnreadBadge?

    var titleColor: Color {
        badgeModel?.titleColor ?? parentBadge?.titleColor ?? .Text.primary
    }

    init(
        widgetBlockId: String,
        details: ObjectDetails,
        spaceId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.widgetBlockId = widgetBlockId
        self.details = details
        self.spaceId = spaceId
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        self.onObjectSelected = onObjectSelected
        self.title = details.pluralTitle
        self.icon = details.objectIconImage
        self.menuViewModel = MyFavoritesRowContextMenuViewModel(
            objectId: details.id,
            spaceId: spaceId,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject
        )
    }

    func onTap() {
        onObjectSelected(details)
    }

    func startSubscriptions() async {
        async let detailsSub: () = startDetailsSubscription()
        async let chatPreviewsSub: () = startChatPreviewsSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        async let unreadDiscussionsSub: () = startUnreadDiscussionsSubscription()
        _ = await (detailsSub, chatPreviewsSub, spaceViewSub, unreadDiscussionsSub)
    }

    // MARK: - Private

    private func startDetailsSubscription() async {
        for await details in personalWidgetsObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            self.details = details
            title = details.pluralTitle
            icon = details.objectIconImage
            updateBadges()
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            let next = previews.first(where: { $0.chatId == objectId })
            guard chatPreview != next else { continue }
            chatPreview = next
            updateBadges()
        }
    }

    private func startSpaceViewSubscription() async {
        for await _ in spaceViewsStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            updateBadges()
        }
    }

    private func startUnreadDiscussionsSubscription() async {
        for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
            let next = unreadBySpace[spaceId]?.parents.first(where: { $0.id == objectId })
            guard unreadParent != next else { continue }
            unreadParent = next
            updateBadges()
        }
    }

    private func updateBadges() {
        let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId)

        let nextChatBadge = chatPreview.flatMap {
            chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
        }
        if badgeModel != nextChatBadge {
            badgeModel = nextChatBadge
        }

        let nextParentBadge = unreadParent.map {
            parentBadgeBuilder.build(parent: $0, spaceView: spaceView)
        }
        if parentBadge != nextParentBadge {
            parentBadge = nextParentBadge
        }
    }
}

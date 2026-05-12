import Foundation
import Services

@MainActor
@Observable
final class UnreadDiscussionParentWidgetViewModel {

    @ObservationIgnored
    private let data: UnreadDiscussionParentWidgetData

    @ObservationIgnored
    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    @ObservationIgnored
    @Injected(\.parentObjectUnreadBadgeBuilder)
    private var badgeBuilder: any ParentObjectUnreadBadgeBuilderProtocol

    @ObservationIgnored
    private var parent: DiscussionUnreadParent?

    private(set) var name: String = ""
    private(set) var icon: Icon?
    private(set) var badge: ParentObjectUnreadBadge?

    init(data: UnreadDiscussionParentWidgetData) {
        self.data = data
    }

    func onHeaderTap() {
        guard let parent else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(
            source: .object(type: parent.details.analyticsType),
            createType: .manual
        )
        data.output?.onObjectSelected(screenData: parent.details.screenData())
    }

    func startSubscriptions() async {
        async let unreadSub: () = startUnreadSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        _ = await (unreadSub, spaceViewSub)
    }

    private func startUnreadSubscription() async {
        for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
            let next = unreadBySpace[data.spaceId]?.parents.first(where: { $0.id == data.id })
            guard parent != next else { continue }
            parent = next
            name = next?.name ?? ""
            icon = next?.details.objectIconImage
            updateBadge()
        }
    }

    private func startSpaceViewSubscription() async {
        for await _ in spaceViewsStorage.spaceViewPublisher(spaceId: data.spaceId).removeDuplicates().values {
            updateBadge()
        }
    }

    private func updateBadge() {
        guard let parent else {
            badge = nil
            return
        }
        let spaceView = spaceViewsStorage.spaceView(spaceId: data.spaceId)
        let next = badgeBuilder.build(parent: parent, spaceView: spaceView)
        if badge != next {
            badge = next
        }
    }
}

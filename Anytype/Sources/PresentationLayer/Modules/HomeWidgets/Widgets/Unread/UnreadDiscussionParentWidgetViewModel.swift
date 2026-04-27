import Foundation
import Services
import AnytypeCore

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
    private var details: ObjectDetails?

    private(set) var name: String = ""
    private(set) var icon: Icon?
    private(set) var unreadCounter: Int = 0
    private(set) var hasMentions: Bool = false
    private(set) var isSubscribed: Bool = false
    private(set) var notificationMode: SpacePushNotificationsMode = .all

    var muted: Bool { notificationMode != .all }

    /// Mention-only (unsubscribed) parents never show the counter pill regardless of muteAndHide.
    /// Subscribed parents follow the chat rule: hidden in `.nothing` mode when muteAndHide is on.
    var shouldShowUnreadCounter: Bool {
        guard isSubscribed, unreadCounter > 0 else { return false }
        guard FeatureFlags.muteAndHide else { return true }
        return notificationMode != .nothing
    }

    init(data: UnreadDiscussionParentWidgetData) {
        self.data = data
    }

    func onHeaderTap() {
        guard let details else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(
            source: .object(type: details.analyticsType),
            createType: .manual
        )
        data.output?.onObjectSelected(screenData: details.screenData())
    }

    func startSubscriptions() async {
        async let unreadSub: () = startUnreadSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        _ = await (unreadSub, spaceViewSub)
    }

    private func startUnreadSubscription() async {
        for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
            guard let parent = unreadBySpace[data.spaceId]?.parents.first(where: { $0.id == data.id }) else {
                continue
            }
            details = parent.details
            name = parent.name
            icon = parent.details.objectIconImage
            unreadCounter = parent.unreadMessageCount
            hasMentions = parent.unreadMentionCount > 0
            isSubscribed = parent.isSubscribed
        }
    }

    private func startSpaceViewSubscription() async {
        for await spaceView in spaceViewsStorage.spaceViewPublisher(spaceId: data.spaceId).values {
            notificationMode = spaceView.pushNotificationMode
        }
    }
}

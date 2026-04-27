import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class HomeWidgetViewModel {

    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var unreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol
    private let data: HomepageWidgetViewData

    var title: String = ""
    var icon: Icon?
    var hasMentions: Bool = false
    var hasUnreadReactions: Bool = false
    var messageCount: Int = 0
    var notificationMode: SpacePushNotificationsMode = .all

    var muted: Bool { !notificationMode.isUnmutedAll }

    var shouldShowUnreadCounter: Bool {
        notificationMode.shouldShowUnreadCounter(unreadCount: messageCount)
    }

    var canSetHomepage: Bool { data.canSetHomepage }

    @ObservationIgnored
    private var details: ObjectDetails?
    @ObservationIgnored
    private var isChatObject: Bool = false

    init(data: HomepageWidgetViewData) {
        self.data = data
    }

    func onHeaderTap() {
        if isChatObject {
            AnytypeAnalytics.instance().logClickWidgetTitle(source: .chat, createType: .manual)
            data.output?.onObjectSelected(screenData: .spaceChat(SpaceChatCoordinatorData(spaceId: data.spaceId)))
        } else if let details {
            AnytypeAnalytics.instance().logClickWidgetTitle(
                source: .object(type: details.analyticsType),
                createType: .manual
            )
            data.onHomeTap(details.screenData())
        }
    }

    func onChangeHomeTap() {
        data.onChangeHome()
    }

    func startSubscriptions() async {
        async let detailsSub: () = startDetailsSubscription()
        async let countersSub: () = startCountersSubscription()
        _ = await (detailsSub, countersSub)
    }

    // MARK: - Private

    private func startDetailsSubscription() async {
        let document = data.document
        for await _ in document.syncPublisher.values {
            guard let details = document.details else { continue }
            self.details = details
            self.title = details.pluralTitle
            self.icon = details.objectIconImage
        }
    }

    private func startCountersSubscription() async {
        let spaceId = data.spaceId
        let objectId = data.objectId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        notificationMode = spaceView?.pushNotificationMode ?? .all

        let chatId = spaceView?.chatId
        isChatObject = chatId == objectId

        if isChatObject, let chatId {
            let sequence = (await chatMessagesPreviewsStorage.previewsSequence)
                .compactMap { $0.first { $0.spaceId == spaceId && $0.chatId == chatId } }
                .removeDuplicates()
                .throttle(milliseconds: 300)

            for await counters in sequence {
                messageCount = counters.unreadCounter
                hasMentions = counters.mentionCounter > 0
                hasUnreadReactions = counters.hasUnreadReactions
            }
        } else {
            for await unreadBySpace in await unreadDiscussionsSubscription.unreadBySpaceSequence {
                let parent = unreadBySpace[spaceId]?.parents.first(where: { $0.id == objectId })
                let nextCount = parent.map { $0.isSubscribed ? $0.unreadMessageCount : 0 } ?? 0
                let nextMentions = (parent?.unreadMentionCount ?? 0) > 0
                guard messageCount != nextCount || hasMentions != nextMentions else { continue }
                messageCount = nextCount
                hasMentions = nextMentions
            }
        }
    }
}

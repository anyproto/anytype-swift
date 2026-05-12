import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class UnreadChatWidgetViewModel {

    @ObservationIgnored
    private let data: UnreadChatWidgetData

    @ObservationIgnored
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    private(set) var name: String = ""
    private(set) var icon: Icon?
    private(set) var unreadCounter: Int = 0
    private(set) var hasMentions: Bool = false
    private(set) var hasUnreadReactions: Bool = false
    private(set) var notificationMode: SpacePushNotificationsMode = .all
    var muted: Bool { notificationMode != .all }

    var shouldShowUnreadCounter: Bool {
        notificationMode.shouldShowUnreadCounter(unreadCount: unreadCounter)
    }

    init(data: UnreadChatWidgetData) {
        self.data = data
    }

    func onHeaderTap() {
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .chat, createType: .manual)
        data.output?.onObjectSelected(screenData: .chat(ChatCoordinatorData(chatId: data.id, spaceId: data.spaceId)))
    }

    func startSubscriptions() async {
        async let detailsSub: () = startDetailsSubscription()
        async let previewsSub: () = startPreviewsSubscription()
        async let mutedSub: () = startMutedSubscription()

        _ = await (detailsSub, previewsSub, mutedSub)
    }

    private func startDetailsSubscription() async {
        for await chats in await chatDetailsStorage.allChatsSequence {
            guard let chat = chats.first(where: { $0.id == data.id }) else { continue }
            name = chat.pluralTitle
            icon = chat.objectIconImage
        }
    }

    private func startMutedSubscription() async {
        for await spaceView in spaceViewsStorage.spaceViewPublisher(spaceId: data.spaceId).values {
            notificationMode = spaceView.effectiveNotificationMode(for: data.id)
        }
    }

    private func startPreviewsSubscription() async {
        let chatId = data.id
        let spaceId = data.spaceId

        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            guard let preview = previews.first(where: { $0.chatId == chatId && $0.spaceId == spaceId }) else {
                continue
            }
            unreadCounter = preview.unreadCounter
            hasMentions = preview.mentionCounter > 0
            hasUnreadReactions = preview.hasUnreadReactions
        }
    }
}

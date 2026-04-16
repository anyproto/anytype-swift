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
    @ObservationIgnored @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol

    private let data: HomepageWidgetViewData

    var title: String = ""
    var icon: Icon?
    var hasMentions: Bool = false
    var hasUnreadReactions: Bool = false
    var messageCount: Int = 0
    var muted = false

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
        async let countersSub: () = startChatCountersSubscription()
        _ = await (detailsSub, countersSub)
    }

    // MARK: - Private

    private func startDetailsSubscription() async {
        // Validity (existence / archived / deleted) is enforced upstream by
        // HomeWidgetsViewModel before HomepageWidgetViewData is emitted, so we only render here.
        let document = documentsProvider.document(objectId: data.objectId, spaceId: data.spaceId, mode: .preview)
        try? await document.open()
        for await _ in document.syncPublisher.values {
            guard let details = document.details else { continue }
            self.details = details
            self.title = details.pluralTitle
            self.icon = details.objectIconImage
        }
    }

    private func startChatCountersSubscription() async {
        let spaceId = data.spaceId
        let objectId = data.objectId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        muted = !(spaceView?.pushNotificationMode.isUnmutedAll ?? true)

        // Counters only apply when the homepage object is the space chat.
        let chatId = spaceView?.chatId
        isChatObject = chatId == objectId
        guard isChatObject else { return }

        let sequence = (await chatMessagesPreviewsStorage.previewsSequence)
            .compactMap { $0.first { $0.spaceId == spaceId && $0.chatId == chatId } }
            .removeDuplicates()
            .throttle(milliseconds: 300)

        for await counters in sequence {
            messageCount = counters.unreadCounter
            hasMentions = counters.mentionCounter > 0
            hasUnreadReactions = counters.hasUnreadReactions
        }
    }
}

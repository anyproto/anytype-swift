import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class SpaceChatWidgetViewModel {

    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol

    private let data: SpaceChatWidgetData

    var hasMentions: Bool = false
    var messageCount: Int = 0
    var muted = false

    private var output: (any CommonWidgetModuleOutput)? { data.output }

    init(data: SpaceChatWidgetData) {
        self.data = data
    }

    func onHeaderTap() {
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .chat, createType: .manual)
        data.output?.onObjectSelected(screenData: .spaceChat(SpaceChatCoordinatorData(spaceId: data.spaceId)))
    }

    func startSubscriptions() async {
        let spaceId = data.spaceId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        muted = !(spaceView?.pushNotificationMode.isUnmutedAll ?? true)

        let chatId = spaceView?.chatId
        let sequence = (await chatMessagesPreviewsStorage.previewsSequence)
            .compactMap { $0.first { $0.spaceId == spaceId && $0.chatId == chatId } }
            .removeDuplicates()
            .throttle(milliseconds: 300)

        for await counters in sequence {
            messageCount = counters.unreadCounter
            hasMentions = counters.mentionCounter > 0
        }
    }
}

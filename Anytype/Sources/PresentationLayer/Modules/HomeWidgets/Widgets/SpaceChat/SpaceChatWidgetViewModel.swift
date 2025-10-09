import Foundation
import Combine
import Services
import AnytypeCore

@MainActor
final class SpaceChatWidgetViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var widgetActionsViewCommonMenuProvider: any WidgetActionsViewCommonMenuProviderProtocol
    
    private let data: SpaceChatWidgetData
    
    @Published var hasMentions: Bool = false
    @Published var messageCount: Int = 0
    @Published var muted = false
    
    private weak var output: (any CommonWidgetModuleOutput)? { data.output }
    
    init(data: SpaceChatWidgetData) {
        self.data = data
    }
    
    func onHeaderTap() {
        guard let chatId = workspaceStorage.spaceView(spaceId: data.spaceId)?.chatId, chatId.isNotEmpty else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .chat, createType: .manual)
        data.output?.onObjectSelected(screenData: .spaceChat(SpaceChatCoordinatorData(spaceId: data.spaceId)))
    }
    
    func startSubscriptions() async {
        let spaceId = data.spaceId
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        muted = FeatureFlags.muteSpacePossibility && !(spaceView?.pushNotificationMode.isUnmutedAll ?? true)
        
        let chatId = spaceView?.chatId
        let sequence = (await chatMessagesPreviewsStorage.previewsSequence)
            .compactMap { $0.first { $0.spaceId == spaceId && $0.chatId ==  chatId }}
            .removeDuplicates()
            .throttle(milliseconds: 300)
        
        for await counters in sequence {
            messageCount = counters.unreadCounter
            hasMentions = counters.mentionCounter > 0
        }
    }
}

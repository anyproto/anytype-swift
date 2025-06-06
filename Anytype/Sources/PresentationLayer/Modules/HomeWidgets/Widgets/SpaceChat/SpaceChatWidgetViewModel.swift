import Foundation
import Combine
import Services

@MainActor
final class SpaceChatWidgetViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var widgetActionsViewCommonMenuProvider: any WidgetActionsViewCommonMenuProviderProtocol
    
    private let data: WidgetSubmoduleData
    
    @Published var hasMentions: Bool = false
    @Published var messageCount: Int = 0
    
    var widgetBlockId: String { data.widgetBlockId }
    var widgetObject: any BaseDocumentProtocol { data.widgetObject }
    weak var output: (any CommonWidgetModuleOutput)? { data.output }
    
    init(data: WidgetSubmoduleData) {
        self.data = data
    }
    
    func onHeaderTap() {
        let spaceId = data.workspaceInfo.accountSpaceId
        guard let chatId = workspaceStorage.spaceView(spaceId: spaceId)?.chatId, chatId.isNotEmpty else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .chat, createType: .manual)
        data.output?.onObjectSelected(screenData: .chat(ChatCoordinatorData(chatId: chatId, spaceId: spaceId)))
    }
    
    func startSubscriptions() async {
        let spaceId = data.workspaceInfo.accountSpaceId
        let chatId = workspaceStorage.spaceView(spaceId: spaceId)?.chatId
        let sequence = (await chatMessagesPreviewsStorage.previewsSequence)
            .compactMap { $0.first { $0.spaceId == spaceId && $0.chatId ==  chatId }}
            .removeDuplicates()
            .throttle(milliseconds: 300)
        
        for await counters in sequence {
            messageCount = counters.unreadCounter
            hasMentions = counters.mentionCounter > 0
        }
    }
    
    func onDeleteWidgetTap() {
        widgetActionsViewCommonMenuProvider.onDeleteWidgetTap(
            widgetObject: data.widgetObject,
            widgetBlockId: data.widgetBlockId,
            homeState: data.homeState.wrappedValue
        )
    }
}

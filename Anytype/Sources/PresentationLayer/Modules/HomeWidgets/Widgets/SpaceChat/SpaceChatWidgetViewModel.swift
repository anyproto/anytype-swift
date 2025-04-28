import Foundation
import Combine
import Services

@MainActor
final class SpaceChatWidgetViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    private let spaceId: String
    private weak var output: (any CommonWidgetModuleOutput)?
    
    init(spaceId: String, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func onHeaderTap() {
        guard let chatId = workspaceStorage.spaceView(spaceId: spaceId)?.chatId, chatId.isNotEmpty else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .chat, createType: .manual)
        output?.onObjectSelected(screenData: .chat(ChatCoordinatorData(chatId: chatId, spaceId: spaceId)))
    }
}

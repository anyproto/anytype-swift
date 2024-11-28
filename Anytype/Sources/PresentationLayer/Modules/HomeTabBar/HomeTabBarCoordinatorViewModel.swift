import Foundation
import Services

@MainActor
final class HomeTabBarCoordinatorViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol

    let spaceInfo: AccountInfo
    
    @Published var spaceIcon: Icon? = nil
    @Published var tab: HomeTabState = .chat
    @Published var bottomPanelState = HomeBottomPanelState()
    @Published var chatData: ChatCoordinatorData?
    @Published var showSpaceSettingsData: AccountInfo?
    
    init(spaceInfo: AccountInfo) {
        self.spaceInfo = spaceInfo
    }

    func startSubscription() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceInfo.accountSpaceId).values {
            spaceIcon = spaceView.objectIconImage
            if let chatId = spaceView.chatId, chatId.isNotEmpty {
                chatData = ChatCoordinatorData(chatId: chatId, spaceId: spaceInfo.accountSpaceId)
            }
        }
    }
    
    func onSpaceSelected() {
        showSpaceSettingsData = spaceInfo
    }
}

import Foundation
import Services

@MainActor
final class HomeTabBarCoordinatorViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol

    let spaceInfo: AccountInfo
    
    @Published var spaceName: String = ""
    @Published var spaceIcon: Icon? = nil
    @Published var tab: HomeTabState = .chat
    @Published var bottomPanelState = HomeBottomPanelState()
    
    init(spaceInfo: AccountInfo) {
        self.spaceInfo = spaceInfo
    }

    func startSubscription() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceInfo.accountSpaceId).values {
            spaceName = spaceView.name
            spaceIcon = spaceView.objectIconImage
        }
    }
}

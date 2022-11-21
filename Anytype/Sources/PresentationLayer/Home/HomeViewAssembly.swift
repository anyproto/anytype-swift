import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(coordinatorsDI: CoordinatorsDIProtocol) {
        self.coordinatorsDI = coordinatorsDI
    }
    
    @MainActor
    func createHomeView() -> HomeView? {
        let homeObjectId = AccountManager.shared.account.info.homeObjectID
        let model = HomeViewModel(
            homeBlockId: homeObjectId,
            editorBrowserAssembly: coordinatorsDI.browser,
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder(),
            windowManager: coordinatorsDI.windowManager
        )
        return HomeView(model: model)
    }
    
}

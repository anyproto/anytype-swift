import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    
    init(coordinatorsDI: CoordinatorsDIProtocol, modulesDI: ModulesDIProtocol) {
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
    }
    
    @MainActor
    func createHomeView() -> HomeView? {
        let homeObjectId = AccountManager.shared.account.info.homeObjectID
        let model = HomeViewModel(
            homeBlockId: homeObjectId,
            editorBrowserAssembly: coordinatorsDI.browser(),
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            windowManager: coordinatorsDI.windowManager()
        )
        return HomeView(model: model)
    }
    
}

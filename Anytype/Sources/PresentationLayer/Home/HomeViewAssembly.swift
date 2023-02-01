import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(coordinatorsDI: CoordinatorsDIProtocol, modulesDI: ModulesDIProtocol, serviceLocator: ServiceLocator) {
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
    }
    
    @MainActor
    func createHomeView() -> HomeView? {
        let homeObjectId = serviceLocator.accountManager().account.info.homeObjectID
        let model = HomeViewModel(
            homeBlockId: homeObjectId,
            editorBrowserAssembly: coordinatorsDI.browser(),
            tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilder(accountManager: serviceLocator.accountManager()),
            profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilder(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            windowManager: coordinatorsDI.windowManager(),
            accountManager: serviceLocator.accountManager(),
            middlewareConfigurationProvider: serviceLocator.middlewareConfigurationProvider()
        )
        return HomeView(model: model)
    }
    
}

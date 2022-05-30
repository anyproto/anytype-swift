import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    func createHomeView() -> HomeView? {
        let homeBlockId = MiddlewareConfigurationProvider.shared.configuration.homeBlockID
        
        return HomeView(model: HomeViewModel(homeBlockId: homeBlockId))
    }
    
}

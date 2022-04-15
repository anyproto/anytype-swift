import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    func createHomeView() -> HomeView? {
        let homeBlockId = MiddlewareConfigurationProvider.shared.configuration.homeBlockID
        guard let id = homeBlockId.asAnytypeId else { return nil }
        
        return HomeView(model: HomeViewModel(homeBlockId: id))
    }
    
}

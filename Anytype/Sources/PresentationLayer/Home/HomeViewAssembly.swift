import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    func createHomeView() -> HomeView? {
        let homeObjectId = AccountManager.shared.account.info.homeObjectID
        
        return HomeView(model: HomeViewModel(homeBlockId: homeObjectId))
    }
    
}

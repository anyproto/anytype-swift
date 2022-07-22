import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    @MainActor
    func createHomeView() -> HomeView? {
        let homeObjectId = AccountManager.shared.account.info.homeObjectID
        
        return HomeView(model: HomeViewModel(homeBlockId: homeObjectId))
    }
    
}

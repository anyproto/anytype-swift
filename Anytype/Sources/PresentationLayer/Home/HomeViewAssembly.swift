import SwiftUI
import AnytypeCore

final class HomeViewAssembly {
    
    private let coordinatorsAssembly: CoordinatorsAssemblyProtocol
    
    init(coordinatorsAssembly: CoordinatorsAssemblyProtocol) {
        self.coordinatorsAssembly = coordinatorsAssembly
    }
    
    @MainActor
    func createHomeView() -> HomeView? {
        let homeObjectId = AccountManager.shared.account.info.homeObjectID
        let model = HomeViewModel(homeBlockId: homeObjectId, editorBrowserAssembly: coordinatorsAssembly.browser)
        return HomeView(model: model)
    }
    
}

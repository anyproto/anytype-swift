import SwiftUI

final class CompletionAuthViewCoordinator {
    
    func routeToHomeView() {
        let homeViewAssembly = HomeViewAssembly()
        windowHolder?.startNewRootView(homeViewAssembly.createHomeView())
    }
    
    // Used as assembly
    func start() -> CompletionAuthView {
        let seedService = ServiceLocator.shared.seedService()
        let viewModel = CompletionAuthViewModel(coordinator: self,
                                                loginStateService: LoginStateService(seedService: seedService))
        var view = CompletionAuthView(viewModel: viewModel)
        view.delegate = viewModel
        
        return view
    }
}

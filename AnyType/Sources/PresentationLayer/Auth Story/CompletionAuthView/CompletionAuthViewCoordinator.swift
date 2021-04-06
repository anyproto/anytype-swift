import SwiftUI

final class CompletionAuthViewCoordinator {
    
    func routeToHomeView() {
        let homeViewAssembly = HomeViewAssembly()
        windowHolder?.startNewRootView(homeViewAssembly.createHomeView())
    }
    
    // Used as assembly
    func start() -> CompletionAuthView {
        let viewModel = CompletionAuthViewModel(coordinator: self)
        var view = CompletionAuthView(viewModel: viewModel)
        view.delegate = viewModel
        
        return view
    }
}

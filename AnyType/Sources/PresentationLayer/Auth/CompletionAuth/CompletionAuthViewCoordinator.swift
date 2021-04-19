import SwiftUI

final class CompletionAuthViewCoordinator {
    
    func routeToOldHomeView() {
        let oldHomeViewAssembly = OldHomeViewAssembly()
        windowHolder?.startNewRootView(oldHomeViewAssembly.createOldHomeView())
    }
    
    // Used as assembly
    func start() -> CompletionAuthView {
        let viewModel = CompletionAuthViewModel(coordinator: self)
        var view = CompletionAuthView(viewModel: viewModel)
        view.delegate = viewModel
        
        return view
    }
}

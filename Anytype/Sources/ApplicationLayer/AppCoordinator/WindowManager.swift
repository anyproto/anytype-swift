import UIKit

final class WindowManager {
    static let shared = WindowManager()
    private let diAssembly: DIAssemblyProtocol = DIAssembly()
    
    @MainActor
    func showHomeWindow() {
        let homeAssembly = diAssembly.coordinatorsAssembly.homeViewAssemby
        windowHolder?.startNewRootView(homeAssembly.createHomeView())
    }
    
    func showAuthWindow() {
        windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
    }
    
    func showLaunchWindow() {
        windowHolder?.startNewRootView(LaunchView())
    }
    
    @MainActor
    func showDeletedAccountWindow(deadline: Date) {
        windowHolder?.startNewRootView(
            DeletedAccountView(
                viewModel: DeletedAccountViewModel(deadline: deadline)
            )
        )
    }
    
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool) {
        windowHolder?.presentOnTop(viewControllerToPresent, animated: flag, completion: nil)
    }
    
    private var windowHolder: WindowHolder? {
        let sceneDeleage = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
        return sceneDeleage?.windowHolder
    }
}

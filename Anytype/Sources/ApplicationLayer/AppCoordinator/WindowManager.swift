import UIKit

final class WindowManager {
    static let shared = WindowManager()
    private let homeAssembly = HomeViewAssembly()
    
    func showHomeWindow() {
        windowHolder?.startNewRootView(homeAssembly.createHomeView())
    }
    
    func showAuthWindow() {
        windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
    }
    
    func showLaunchWindow() {
        windowHolder?.startNewRootView(LaunchView())
    }
    
    func showDeletedAccountWindow(progress: DeletionProgress) {
        windowHolder?.startNewRootView(
            DeletedAccountView(
                viewModel: DeletedAccountViewModel(progress: progress)
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

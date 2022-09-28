import UIKit

final class WindowManager {
    static let shared = WindowManager()
    private let di: DIProtocol = DI()

    private weak var lastHomeViewModel: HomeViewModel?

    @MainActor
    func showHomeWindow() {
        let homeAssembly = di.coordinatorsDI.homeViewAssemby
        let homeView = homeAssembly.createHomeView()

        self.lastHomeViewModel = homeView?.model
        windowHolder?.startNewRootView(homeView)
    }
    
    func showAuthWindow() {
        windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
    }
    
    func showLaunchWindow() {
        windowHolder?.startNewRootView(LaunchView())
    }

    @MainActor
    func createAndShowNewObject() {
        lastHomeViewModel?.createAndShowNewPage()
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

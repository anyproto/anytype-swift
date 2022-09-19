import UIKit

final class WindowManager {
    static let shared = WindowManager()
    private let di: DIProtocol = DI()

    private var lastHomeView: HomeView?

    @MainActor
    func showHomeWindow() {
        let homeAssembly = di.coordinatorsDI.homeViewAssemby
        let homeView = homeAssembly.createHomeView()

        self.lastHomeView = homeView
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
        guard let lastHomeView = lastHomeView else { return }

        lastHomeView.model.createAndShowNewPage()
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

import UIKit
import SwiftUI
import Combine


class ApplicationCoordinator {
    private let window: MainWindow
    
    private let shakeHandler: ShakeHandler
    
    private let authService: AuthServiceProtocol
    private let firebaseService: FirebaseService
    
    private let authAssembly: AuthAssembly
    
    private(set) lazy var rootNavigationController = createNavigationController()
    
    init(
        window: MainWindow,
        shakeHandler: ShakeHandler,
        authService: AuthServiceProtocol,
        firebaseService: FirebaseService,
        authAssembly: AuthAssembly
    ) {
        self.window = window
        self.shakeHandler = shakeHandler
        
        self.authService = authService
        self.firebaseService = firebaseService
        
        self.authAssembly = authAssembly
    }

    func start() {
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        
        runAtFirstLaunch()
        runServicesOnStartup()
        login()
    }
    
    private func runAtFirstLaunch() {
        if UserDefaultsConfig.installedAtDate.isNil {
            UserDefaultsConfig.installedAtDate = Date()
        }
    }
    
    private func runServicesOnStartup() {
        shakeHandler.run()
        firebaseService.setup()
    }

    private func login() {
        let userId = UserDefaultsConfig.usersIdKey // TODO: Remove static
        guard userId.isEmpty == false else {
            showAuthScreen()
            return
        }
        
        self.authService.selectAccount(id: userId) { [weak self] result in
            switch result {
            case .success:
                self?.showHomeScreen()
            case .failure:
                self?.showAuthScreen()
            }
        }
    }
    
    private func showHomeScreen() {
        let homeAssembly = HomeViewAssembly()
        let view = homeAssembly.createHomeView()
        
        startNewRootView(view)
    }
    
    private func showAuthScreen() {
        startNewRootView(authAssembly.authView())
    }
        
    fileprivate func createNavigationController() -> UINavigationController {
        let controller = UINavigationController()
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
                
        controller.navigationBar.compactAppearance = navBarAppearance
        controller.navigationBar.standardAppearance = navBarAppearance
        controller.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        controller.navigationBar.barTintColor = UIColor.grayscale50
        controller.navigationBar.tintColor = UIColor.grayscale50

        return controller
    }
}

// MARK: - MainWindowHolder
protocol MainWindowHolder {
    func startNewRootView<ViewType: View>(_ view: ViewType)
    
    var rootNavigationController: UINavigationController { get }
    func modifyNavigationBarAppearance(_ appearance: UINavigationBarAppearance)

}

extension ApplicationCoordinator: MainWindowHolder {
    
    func startNewRootView<ViewType: View>(_ view: ViewType) {
        let rootNavigationController = createNavigationController()
        rootNavigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
        self.rootNavigationController = rootNavigationController
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
    
    func modifyNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        rootNavigationController.navigationBar.compactAppearance = appearance
        rootNavigationController.navigationBar.standardAppearance = appearance
        rootNavigationController.navigationBar.scrollEdgeAppearance = appearance
        rootNavigationController.navigationBar.barTintColor = UIColor.grayscale50
        rootNavigationController.navigationBar.tintColor = UIColor.grayscale50
    }

}

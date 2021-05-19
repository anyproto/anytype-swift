import UIKit
import SwiftUI
import Combine


class ApplicationCoordinator {
    private let window: MainWindow
    
    private let shakeHandler: ShakeHandler
    
    private let localRepoService: LocalRepoServiceProtocol
    private let authService: AuthServiceProtocol
    private let firebaseService: FirebaseService
    
    private let authAssembly: AuthAssembly
    
    init(
        window: MainWindow,
        shakeHandler: ShakeHandler,
        localRepoService: LocalRepoServiceProtocol,
        authService: AuthServiceProtocol,
        firebaseService: FirebaseService,
        authAssembly: AuthAssembly
    ) {
        self.window = window
        self.shakeHandler = shakeHandler
        
        self.localRepoService = localRepoService
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
        
        self.authService.selectAccount(id: userId, path: localRepoService.middlewareRepoPath) { [weak self] result in
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
    
    // MARK: - rootNavigationController
    let rootNavigationController: UINavigationController = {
        let controller = UINavigationController()
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
                
        controller.navigationBar.compactAppearance = navBarAppearance
        controller.navigationBar.standardAppearance = navBarAppearance
        controller.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        controller.navigationBar.barTintColor = UIColor.grayscale50
        controller.navigationBar.tintColor = UIColor.grayscale50

        return controller
    }()
}

// MARK: - MainWindowHolder
protocol MainWindowHolder {
    func startNewRootView<ViewType: View>(_ view: ViewType)
    
    var rootNavigationController: UINavigationController { get }
    func changeNavigationBarCollor(color: UIColor)
}

extension ApplicationCoordinator: MainWindowHolder {
    func startNewRootView<ViewType: View>(_ view: ViewType) {
        rootNavigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
    }
    
    func changeNavigationBarCollor(color: UIColor) {
        rootNavigationController.navigationBar.backgroundColor = color
    }
}

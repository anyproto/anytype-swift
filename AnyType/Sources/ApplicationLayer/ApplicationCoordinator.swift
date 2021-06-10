import UIKit
import SwiftUI
import Combine

final class ApplicationCoordinator {
    
    // MARK: - Private variables
    
    private let window: MainWindow
    
    private let shakeHandler: ShakeHandler
    
    private let authService: AuthServiceProtocol
    private let firebaseService: FirebaseService
    
    private let authAssembly: AuthAssembly
    
    private(set) lazy var rootNavigationController = createNavigationController()
    
    // MARK: - Initializers
    
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

// MARK: - Private extension

private extension ApplicationCoordinator {
 
    func runAtFirstLaunch() {
        guard UserDefaultsConfig.installedAtDate.isNil else { return }
        
        UserDefaultsConfig.installedAtDate = Date()
    }
    
    func runServicesOnStartup() {
        shakeHandler.run()
        firebaseService.setup()
    }

    func login() {
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
    
    func showHomeScreen() {
        let homeAssembly = HomeViewAssembly()
        let view = homeAssembly.createHomeView()
        
        startNewRootView(view)
    }
    
    func showAuthScreen() {
        startNewRootView(authAssembly.authView())
    }
    
}

// MARK: - MainWindowHolde

extension ApplicationCoordinator: MainWindowHolder {
    
    func startNewRootView<ViewType: View>(_ view: ViewType) {
        let rootNavigationController = createNavigationController()
        rootNavigationController.setViewControllers(
            [UIHostingController(rootView: view)],
            animated: false
        )
        self.rootNavigationController = rootNavigationController
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
    
    func configureNavigationBarWithOpaqueBackground() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.shadowColor = nil
        
        modifyNavigationBarAppearance(navBarAppearance)
    }
    
    func configureNavigationBarWithTransparentBackground() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        
        modifyNavigationBarAppearance(navBarAppearance)
    }
    
    private func modifyNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        rootNavigationController.navigationBar.compactAppearance = appearance
        rootNavigationController.navigationBar.standardAppearance = appearance
        rootNavigationController.navigationBar.scrollEdgeAppearance = appearance
        rootNavigationController.navigationBar.barTintColor = UIColor.grayscale50
        rootNavigationController.navigationBar.tintColor = UIColor.grayscale50
    }
}

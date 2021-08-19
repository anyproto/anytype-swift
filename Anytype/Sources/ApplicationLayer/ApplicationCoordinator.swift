import UIKit
import SwiftUI
import Combine
import AnytypeCore

final class ApplicationCoordinator {
    
    private let window: MainWindow
    
    private let authService: AuthServiceProtocol
    
    private let authAssembly: AuthAssembly
    
    private(set) lazy var rootNavigationController = createNavigationController()
    
    // MARK: - Initializers
    
    init(
        window: MainWindow,
        authService: AuthServiceProtocol,
        authAssembly: AuthAssembly
    ) {
        self.window = window
        
        self.authService = authService
        
        self.authAssembly = authAssembly
    }

    func start() {
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        
        runAtFirstLaunch()
        login()
    }
        
    fileprivate func createNavigationController() -> UINavigationController {
        let controller = UINavigationController()
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        
        modifyNavigationBarAppearance(navBarAppearance, controller)

        return controller
    }
}

// MARK: - Private extension

private extension ApplicationCoordinator {
 
    func runAtFirstLaunch() {
        guard UserDefaultsConfig.installedAtDate.isNil else { return }
        
        UserDefaultsConfig.installedAtDate = Date()
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
                guard let self = self else { return }
                
                self.configureMiddlewareConfiguration()
                self.showHomeScreen()
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
    
    func configureMiddlewareConfiguration() {
        MiddlewareConfigurationService.shared.obtainAndCacheConfiguration()
    }
    
    private func modifyNavigationBarAppearance(_ appearance: UINavigationBarAppearance,
                                               _ vc: UINavigationController) {
        vc.navigationBar.compactAppearance = appearance
        vc.navigationBar.standardAppearance = appearance
        vc.navigationBar.scrollEdgeAppearance = appearance
        vc.navigationBar.barTintColor = UIColor.grayscaleWhite
        vc.navigationBar.tintColor = UIColor.grayscaleWhite
    }
    
}

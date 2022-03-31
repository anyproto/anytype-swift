import UIKit
import SwiftUI
import Combine
import AnytypeCore
import BlocksModels

final class ApplicationCoordinator {
    
    private let window: UIWindow
    
    private let authService: AuthServiceProtocol
    
    private(set) lazy var rootNavigationController = createNavigationController()
    
    // MARK: - Initializers
    
    init(window: UIWindow, authService: AuthServiceProtocol) {
        self.window = window
        self.authService = authService
    }

    func start() {
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        
        runAtFirstLaunch()
        login()
    }
        
    fileprivate func createNavigationController() -> UINavigationController {
        let controller: UINavigationController
        
        if #available(iOS 14.0, *) {
            controller = iOS14SwiftUINavigationController()
        } else {
            controller = UINavigationController()
        }
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        
        controller.modifyBarAppearance(navBarAppearance)

        return controller
    }
}

// MARK: - Private extension

private extension ApplicationCoordinator {
 
    func runAtFirstLaunch() {
        if UserDefaultsConfig.defaultObjectType.isEmpty {
            if UserDefaultsConfig.installedAtDate.isNil { // First launch
                UserDefaultsConfig.defaultObjectType = ObjectTemplateType.bundled(.note).rawValue
            } else {
                UserDefaultsConfig.defaultObjectType = ObjectTemplateType.bundled(.page).rawValue
            }
        }
        
        
        if UserDefaultsConfig.installedAtDate.isNil {
            UserDefaultsConfig.installedAtDate = Date()
        }
    }

    func login() {
        let userId = UserDefaultsConfig.usersId
        guard userId.isNotEmpty else {
            WindowManager.shared.showAuthWindow()
            return
        }
        
        switch authService.selectAccount(id: userId) {
        case .active:
            WindowManager.shared.showHomeWindow()
        case .pendingDeletion(progress: let progress):
            WindowManager.shared.showDeletedAccountWindow(progress: progress)
        case .deleted, .none:
            WindowManager.shared.showAuthWindow()
        }
    }
} 

// MARK: - MainWindowHolde

extension ApplicationCoordinator: WindowHolder {
    
    func startNewRootView<ViewType: View>(_ view: ViewType) {
        window.makeKeyAndVisible()
        let rootNavigationController = createNavigationController()
        rootNavigationController.setViewControllers(
            [UIHostingController(rootView: view)],
            animated: false
        )
        self.rootNavigationController = rootNavigationController
        
        
        window.rootViewController = rootNavigationController
    }
    
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        rootNavigationController.topPresentedController.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

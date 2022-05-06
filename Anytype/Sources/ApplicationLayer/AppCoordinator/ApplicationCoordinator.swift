import UIKit
import SwiftUI
import Combine
import AnytypeCore
import BlocksModels

final class ApplicationCoordinator {
    
    private let window: UIWindow
    
    private let authService: AuthServiceProtocol
        
    // MARK: - Initializers
    
    init(window: UIWindow, authService: AuthServiceProtocol) {
        self.window = window
        self.authService = authService
    }

    func start() {
        runAtFirstLaunch()
        login()
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
        let controller = iOS14SwiftUINavigationController(
            rootViewController: UIHostingController(rootView: view)
        )
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        controller.modifyBarAppearance(navBarAppearance)
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        window.rootViewController?.topPresentedController.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

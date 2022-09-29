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

    @MainActor
    func start(connectionOptions: UIScene.ConnectionOptions) {
        runAtFirstLaunch()
        login(connectionOptions: connectionOptions)
    }

    @MainActor
    func handleDeeplink(url: URL) {
        switch url {
        case URLConstants.createObjectURL:
            WindowManager.shared.createAndShowNewObject()
        default:
            break
        }
    }
}

// MARK: - Private extension

private extension ApplicationCoordinator {
 
    func runAtFirstLaunch() {
        if UserDefaultsConfig.installedAtDate.isNil {
            UserDefaultsConfig.installedAtDate = Date()
        }
    }

    @MainActor
    func login(connectionOptions: UIScene.ConnectionOptions) {
        let userId = UserDefaultsConfig.usersId
        guard userId.isNotEmpty else {
            WindowManager.shared.showAuthWindow()
            return
        }
        
        WindowManager.shared.showLaunchWindow()
        
        authService.selectAccount(id: userId) { [weak self] result in
            switch result {
            case .active:
                WindowManager.shared.showHomeWindow()
            case .pendingDeletion(let deadline):
                WindowManager.shared.showDeletedAccountWindow(deadline: deadline)
            case .deleted, .none:
                WindowManager.shared.showAuthWindow()
            }

            connectionOptions
                .urlContexts
                .map(\.url)
                .first
                .map { self?.handleDeeplink(url: $0) }
        }
    }
} 

// MARK: - MainWindowHolde

extension ApplicationCoordinator: WindowHolder {
    
    func startNewRootView<ViewType: View>(_ view: ViewType) {
        let controller = NavigationControllerWithSwiftUIContent(
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

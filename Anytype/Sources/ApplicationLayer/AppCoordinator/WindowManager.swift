import UIKit
import SwiftUI
import AnytypeCore

final class WindowManager {
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    private let homeViewAssembly: HomeViewAssembly
    private let homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    
    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        homeViewAssembly: HomeViewAssembly,
        homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.homeViewAssembly = homeViewAssembly
        self.homeWidgetsCoordinatorAssembly = homeWidgetsCoordinatorAssembly
    }

    private var homeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol?
    private weak var lastHomeViewModel: HomeViewModel?

    @MainActor
    func showHomeWindow() {
        if FeatureFlags.homeWidgets {
            let coordinator = homeWidgetsCoordinatorAssembly.make()
            self.homeWidgetsCoordinator = coordinator
            let homeView = coordinator.startFlow()
            startNewRootView(homeView)
        } else {
            let homeView = homeViewAssembly.createHomeView()
            
            self.lastHomeViewModel = homeView?.model
            startNewRootView(homeView)
        }
    }
    
    func showAuthWindow() {
        startNewRootView(MainAuthView(viewModel: MainAuthViewModel(windowManager: self)))
    }
    
    func showLaunchWindow() {
        startNewRootView(LaunchView())
    }

    @MainActor
    func createAndShowNewObject() {
        if FeatureFlags.homeWidgets {
            // TODO: IOS-746
        } else {
            lastHomeViewModel?.createAndShowNewPage()
        }
    }
    
    @MainActor
    func showDeletedAccountWindow(deadline: Date) {
        startNewRootView(
            DeletedAccountView(
                viewModel: DeletedAccountViewModel(deadline: deadline, windowManager: self)
            )
        )
    }
    
    // MARK: - Private
    
    private func startNewRootView<ViewType: View>(_ view: ViewType) {
        let controller = NavigationControllerWithSwiftUIContent(
            rootViewController: UIHostingController(rootView: view)
        )
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        controller.modifyBarAppearance(navBarAppearance)
        
        let window = viewControllerProvider.window
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
}

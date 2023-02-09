import UIKit
import SwiftUI
import AnytypeCore

final class WindowManager {
    
    // MARK: - DI
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    private let homeViewAssembly: HomeViewAssembly
    private let homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    // MARK: - State
    
    private var homeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol?
    private weak var lastHomeViewModel: HomeViewModel?
    
    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        homeViewAssembly: HomeViewAssembly,
        homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol,
        applicationStateService: ApplicationStateServiceProtocol
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.homeViewAssembly = homeViewAssembly
        self.homeWidgetsCoordinatorAssembly = homeWidgetsCoordinatorAssembly
        self.applicationStateService = applicationStateService
    }

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
        startNewRootView(MainAuthView(viewModel: MainAuthViewModel(applicationStateService: applicationStateService)))
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
                viewModel: DeletedAccountViewModel(deadline: deadline, applicationStateService: applicationStateService)
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

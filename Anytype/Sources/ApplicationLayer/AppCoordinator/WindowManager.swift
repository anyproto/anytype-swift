import UIKit
import SwiftUI
import AnytypeCore

final class WindowManager {
    
    // MARK: - DI
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    private let authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol
    private let legacyAuthViewAssembly: LegacyAuthViewAssembly
    private let homeViewAssembly: HomeViewAssembly
    private let homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    // MARK: - State
    
    private var homeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol?
    private weak var lastHomeViewModel: HomeViewModel?
    
    private var authCoordinator: AuthCoordinatorProtocol?
    
    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol,
        legacyAuthViewAssembly: LegacyAuthViewAssembly,
        homeViewAssembly: HomeViewAssembly,
        homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol,
        applicationStateService: ApplicationStateServiceProtocol
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.authCoordinatorAssembly = authCoordinatorAssembly
        self.legacyAuthViewAssembly = legacyAuthViewAssembly
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
            coordinator.flowStarted()
        } else {
            let homeView = homeViewAssembly.createHomeView()
            
            self.lastHomeViewModel = homeView?.model
            startNewRootView(homeView)
        }
    }
    
    @MainActor
    func showAuthWindow() {
        if FeatureFlags.newAuthorization {
            let coordinator = authCoordinatorAssembly.make()
            self.authCoordinator = coordinator
            let authView = coordinator.startFlow()
            startNewRootView(authView)
        } else {
            let legacyAuthView = legacyAuthViewAssembly.createAuthView()
            startNewRootView(legacyAuthView)
        }
    }
    
    func showLaunchWindow() {
        startNewRootView(LaunchView())
    }

    @MainActor
    func createAndShowNewObject() {
        if FeatureFlags.homeWidgets {
            homeWidgetsCoordinator?.createAndShowNewPage()
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
        
        let controller = FeatureFlags.homeWidgets
            ? UINavigationController(rootViewController: AnytypeHostingController(rootView: view))
            : NavigationControllerWithSwiftUIContent(rootViewController: UIHostingController(rootView: view))
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        controller.modifyBarAppearance(navBarAppearance)
        
        let window = viewControllerProvider.window
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
}

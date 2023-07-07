import UIKit
import SwiftUI
import AnytypeCore

final class WindowManager {
    
    // MARK: - DI
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    private let authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol
    private let legacyAuthViewAssembly: LegacyAuthViewAssembly
    private let homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    // MARK: - State
    
    private var homeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol?
    
    private var authCoordinator: AuthCoordinatorProtocol?
    
    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol,
        legacyAuthViewAssembly: LegacyAuthViewAssembly,
        homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol,
        applicationStateService: ApplicationStateServiceProtocol
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.authCoordinatorAssembly = authCoordinatorAssembly
        self.legacyAuthViewAssembly = legacyAuthViewAssembly
        self.homeWidgetsCoordinatorAssembly = homeWidgetsCoordinatorAssembly
        self.applicationStateService = applicationStateService
    }

    @MainActor
    func showHomeWindow() {
        let coordinator = homeWidgetsCoordinatorAssembly.make()
        self.homeWidgetsCoordinator = coordinator
        let homeView = coordinator.startFlow()
        startNewRootView(homeView)
        coordinator.flowStarted()
    }
    
    @MainActor
    func showAuthWindow() {
        if FeatureFlags.newAuthorization {
            let coordinator = authCoordinatorAssembly.make()
            self.authCoordinator = coordinator
            let authView = coordinator.startFlow()
            startNewRootView(authView, preferredColorScheme: .dark, disableBackSwipe: true)
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
        homeWidgetsCoordinator?.createAndShowNewPage()
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
    
    private func startNewRootView<ViewType: View>(
        _ view: ViewType,
        preferredColorScheme: UIUserInterfaceStyle? = nil,
        disableBackSwipe: Bool = false
    ) {
        
        let controller = BaseNavigationController(rootViewController: AnytypeHostingController(rootView: view))
        controller.disableBackSwipe = disableBackSwipe
        
        if let preferredColorScheme {
            controller.overrideUserInterfaceStyle = preferredColorScheme
        }
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        controller.modifyBarAppearance(navBarAppearance)
        
        let window = viewControllerProvider.window
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
}

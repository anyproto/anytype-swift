import UIKit
import SwiftUI

final class WindowManager {
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    private let homeViewAssembly: HomeViewAssembly
    
    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        homeViewAssembly: HomeViewAssembly
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.homeViewAssembly = homeViewAssembly
    }

    private weak var lastHomeViewModel: HomeViewModel?

    @MainActor
    func showHomeWindow() {
        let homeView = homeViewAssembly.createHomeView()

        self.lastHomeViewModel = homeView?.model
        startNewRootView(homeView)
    }
    
    func showAuthWindow() {
        startNewRootView(MainAuthView(viewModel: MainAuthViewModel(windowManager: self)))
    }
    
    func showLaunchWindow() {
        startNewRootView(LaunchView())
    }

    @MainActor
    func createAndShowNewObject() {
        lastHomeViewModel?.createAndShowNewPage()
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
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}

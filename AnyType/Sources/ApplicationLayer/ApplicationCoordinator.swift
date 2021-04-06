import UIKit
import SwiftUI
import Combine

protocol MainWindowHolder {
    func startNewRootView<ViewType: View>(_ view: ViewType)
}

class ApplicationCoordinator: MainWindowHolder {
    private let window: MainWindow
    
    private let pageScrollViewLayout = GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout()
    private let shakeHandler: ShakeHandler
    
    private let developerOptionsService: DeveloperOptionsService
    private let localRepoService: LocalRepoService
    private let authService: AuthService
    private let appearanceService: AppearanceService
    private let firebaseService: FirebaseService
    
    init(
        window: MainWindow,
        developerOptionsService: DeveloperOptionsService,
        localRepoService: LocalRepoService,
        authService: AuthService,
        appearanceService: AppearanceService,
        firebaseService: FirebaseService
    ) {
        self.window = window
        self.shakeHandler = .init(window)
        
        self.developerOptionsService = developerOptionsService
        self.localRepoService = localRepoService
        self.authService = authService
        self.appearanceService = appearanceService
        self.firebaseService = firebaseService
    }

    func start() {
        runAtFirstLaunch()
        runServicesOnStartup()
        
        let shouldSkipLogin = developerOptionsService.current.workflow.authentication.shouldSkipLogin
        shouldSkipLogin ? showHomeScreen() : login()
    }
    
    private func runAtFirstLaunch() {
        if UserDefaultsConfig.installedAtDate == nil {
            UserDefaultsConfig.installedAtDate = Date()
            developerOptionsService.runAtFirstTime()
        }
    }
    
    private func runServicesOnStartup() {
        appearanceService.resetToDefaults()
        firebaseService.setup()
    }

    // MARK: Login
    private func login() {
        if shouldShowFocusedPage() {
            showFocusedPage()
            return
        }
        
        let userId = UserDefaultsConfig.usersIdKey // TODO: Remove static
        guard userId.isEmpty == false else {
            showAuthScreen()
            return
        }
        
        self.authService.selectAccount(id: userId, path: localRepoService.middlewareRepoPath) { [weak self] result in
            switch result {
            case .success:
                self?.showHomeScreen()
            case .failure:
                self?.showAuthScreen()
            }
        }
    }
    
    private func shouldShowFocusedPage() -> Bool {
        let shouldShowFocusedPageId = developerOptionsService.current.workflow.authentication.shouldShowFocusedPageId
        let focusedPageIdExists = developerOptionsService.current.workflow.authentication.focusedPageId.isEmpty == false
        return shouldShowFocusedPageId && focusedPageIdExists
    }
    
    private func showFocusedPage() {
        let pageId = developerOptionsService.current.workflow.authentication.focusedPageId
        let controller = EditorModule.Container.ViewBuilder.UIKitBuilder.view(by: .init(id: pageId))
        self.startNewRootViewController(controller)
    }
    
    private func showHomeScreen() {
        let homeAssembly = HomeViewAssembly()
        let view = homeAssembly.createHomeView()
        self.startNewRootView(view)
    }
    
    private func showAuthScreen() {
        startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
    }
    
    private func startNewRootViewController(_ controller: UIViewController) {
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
    
    // MARK: - MainWindowHolder
    func startNewRootView<ViewType: View>(_ view: ViewType) {
        window.rootViewController = UIHostingController(rootView: view.environmentObject(self.pageScrollViewLayout))
        window.makeKeyAndVisible()
    }
}

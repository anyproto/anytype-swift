import UIKit
import SwiftUI
import Combine


/// First coordinator that start ui flow
class ApplicationCoordinator {
    @Environment(\.authService) private var authService
    private let localRepoService: LocalRepoService = ServiceLocator.shared.resolve()
    
    private let window: UIWindow
    private let keychainStore = KeychainStoreService()
    private let pageScrollViewLayout = GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout()
    private let shakeHandler: ShakeHandler
    
    private let developerOptionsService: DeveloperOptionsService
    
    init(
        window: UIWindow,
        developerOptionsService: DeveloperOptionsService
    ) {
        self.window = window
        self.shakeHandler = .init(window)
        
        self.developerOptionsService = developerOptionsService
    }

    func start() {
        self.runAtFirstTime()
        
        if developerOptionsService.current.workflow.authentication.shouldSkipLogin {
            let homeAssembly = HomeViewAssembly()
            let view = homeAssembly.createHomeView()
            self.startNewRootView(content: view)
        }
        else {
            self.login(id: UserDefaultsConfig.usersIdKey)
        }
    }
    
    func startNewRootView<Content: View>(content: Content) {
        window.rootViewController = UIHostingController(rootView: content.environmentObject(self.pageScrollViewLayout))
        window.makeKeyAndVisible()
    }
    
    private func runAtFirstTime() {
        if UserDefaultsConfig.installedAtDate == nil {
            UserDefaultsConfig.installedAtDate = Date()
            developerOptionsService.runAtFirstTime()
        }
    }

    // MARK: Login
    private func login(id: String) {
        guard id.isEmpty == false else {
            self.processLogin(result: .failure(.loginError(message: "")))
            return
        }
        
        self.authService.selectAccount(id: id, path: localRepoService.middlewareRepoPath) { [weak self] result in
            self?.processLogin(result: result)
        }
    }
    
    private func processLogin(result: Result<String, AuthServiceError>) {
        if developerOptionsService.current.workflow.authentication.shouldShowFocusedPageId && !developerOptionsService.current.workflow.authentication.focusedPageId.isEmpty {
            let pageId = developerOptionsService.current.workflow.authentication.focusedPageId
            let controller = EditorModule.Container.ViewBuilder.UIKitBuilder.view(by: .init(id: pageId))
            self.startNewRootViewController(controller)
            return
        }
        
        switch result {
        case .success:
            let homeAssembly = HomeViewAssembly()
            let view = homeAssembly.createHomeView()
            self.startNewRootView(content: view)
        case .failure:
            let view = MainAuthView(viewModel: MainAuthViewModel())
            self.startNewRootView(content: view)
        }
    }
    
    private func startNewRootViewController(_ controller: UIViewController) {
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}

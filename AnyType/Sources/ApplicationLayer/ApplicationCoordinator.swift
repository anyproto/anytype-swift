import UIKit
import SwiftUI
import Combine


/// First coordinator that start ui flow
class ApplicationCoordinator {
    @Environment(\.authService) private var authService
    @Environment(\.localRepoService) private var localRepoService
    @Environment(\.developerOptions) private var developerOptions
    
    private let window: UIWindow
    private let keychainStore = KeychainStoreService()
    private let pageScrollViewLayout = GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout()
    private var shakeHandler: ShakeHandler?
    // MARK: - Lifecycle
    
    init(window: UIWindow) {
        self.window = window
        self.shakeHandler = .init(window)
    }

    // MARK: - Public methods
    
    func start() {
        self.prepareForStart { [weak self] (completed) in
            self?.startBegin()
        }
    }
    
    func startBegin() {
        if developerOptions.current.workflow.authentication.shouldSkipLogin {
            let homeAssembly = HomeViewAssembly()
            let view = homeAssembly.createHomeView()
            self.startNewRootView(content: view)
        }
        else {
            self.login(id: UserDefaultsConfig.usersIdKey)
        }
    }

    // MARK: Start Preparation.
    func runAtFirstTime() {
        if UserDefaultsConfig.installedAtDate == nil {
            UserDefaultsConfig.installedAtDate = .init()
            self.developerOptions.runAtFirstTime()
        }
    }
    
    func prepareForStart(_ completed: @escaping (Bool) -> ()) {
        self.runAtFirstTime()
        completed(true)
    }

    // MARK: Start new root
    func startNewRootView<Content: View>(content: Content) {
        window.rootViewController = UIHostingController(rootView: content.environmentObject(self.pageScrollViewLayout))
        window.makeKeyAndVisible()
    }
    
    func startNewRootViewController(_ controller: UIViewController) {
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    // MARK: Login
    private func processLogin(result: Result<String, AuthServiceError>) {
        if self.developerOptions.current.workflow.authentication.shouldShowFocusedPageId && !self.developerOptions.current.workflow.authentication.focusedPageId.isEmpty {
            let pageId = self.developerOptions.current.workflow.authentication.focusedPageId
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
    
    private func login(id: String) {
        guard id.isEmpty == false else {
            self.processLogin(result: .failure(.loginError(message: "")))
            return
        }
        
        self.authService.selectAccount(id: id, path: localRepoService.middlewareRepoPath) { [weak self] result in
            self?.processLogin(result: result)
        }
    }
}

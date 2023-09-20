import SwiftUI
import Combine
import AnytypeCore
import Services
import NavigationBackport

//@MainActor
//protocol ApplicationCoordinatorProtocol: AnyObject {
//    func start(connectionOptions: UIScene.ConnectionOptions)
//    func handleDeeplink(url: URL)
//}

@MainActor
final class ApplicationCoordinatorViewModel: ObservableObject {
    
//    private let windowManager: WindowManager
    private let authService: AuthServiceProtocol
    private let accountEventHandler: AccountEventHandlerProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let seedService: SeedServiceProtocol
    private let fileErrorEventHandler: FileErrorEventHandlerProtocol
    private let toastPresenter: ToastPresenterProtocol
    
    private let authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol
    private let homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    
    private var authCoordinator: AuthCoordinatorProtocol?
    // MARK: - State
    
    @Published var applicationState: ApplicationState = .initial
    
//    private var connectionOptions: UIScene.ConnectionOptions?
    
    // MARK: - Initializers
    
    init(
//        windowManager: WindowManager,
        authService: AuthServiceProtocol,
        accountEventHandler: AccountEventHandlerProtocol,
        applicationStateService: ApplicationStateServiceProtocol,
        accountManager: AccountManagerProtocol,
        seedService: SeedServiceProtocol,
        fileErrorEventHandler: FileErrorEventHandlerProtocol,
        toastPresenter: ToastPresenterProtocol,
        authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol,
        homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    ) {
//        self.windowManager = windowManager
        self.authService = authService
        self.accountEventHandler = accountEventHandler
        self.applicationStateService = applicationStateService
        self.accountManager = accountManager
        self.seedService = seedService
        self.fileErrorEventHandler = fileErrorEventHandler
        self.toastPresenter = toastPresenter
        self.authCoordinatorAssembly = authCoordinatorAssembly
        self.homeWidgetsCoordinatorAssembly = homeWidgetsCoordinatorAssembly
    }
    
    func onAppear() {
        runAtFirstLaunch()
        startObserve()
    }

//    func start(connectionOptions: UIScene.ConnectionOptions) {
//        self.connectionOptions = connectionOptions
//        runAtFirstLaunch()
//        startObserve()
//    }
    
    // TODO: Navigation: Fix handling
    
    func handleDeeplink(url: URL) {
        guard applicationStateService.state == .home else { return }
        switch url {
        case URLConstants.createObjectURL:
            break
//            windowManager.createAndShowNewObject()
        default:
            break
        }
    }
    
    func authView() -> AnyView {
        if let authCoordinator {
            return authCoordinator.startFlow()
        }
        let coordinator = authCoordinatorAssembly.make()
        self.authCoordinator = coordinator
        return coordinator.startFlow()
    }
    
    func homeView() -> AnyView {
        return homeWidgetsCoordinatorAssembly.make()
    }
    
    // MARK: - Subscription

    private func startObserve() {
        Task { @MainActor [weak self, applicationStateService] in
            for await state in applicationStateService.statePublisher.values {
                guard let self = self else { return }
                self.handleApplicationState(state)
            }
        }
        Task { @MainActor [weak self, accountEventHandler] in
            for await status in accountEventHandler.accountStatusPublisher.values {
                guard let self = self else { return }
                self.handleAccountStatus(status)
            }
        }
        Task { @MainActor [weak self, fileErrorEventHandler] in
            for await _ in fileErrorEventHandler.fileLimitReachedPublisher.values {
                guard let self = self else { return }
                self.handleFileLimitReachedError()
            }
        }
    }
    
    private func runAtFirstLaunch() {
        if UserDefaultsConfig.installedAtDate.isNil {
            UserDefaultsConfig.installedAtDate = Date()
        }
    }
    
    // MARK: - Subscription handler

    private func handleAccountStatus(_ status: AccountStatus) {
        switch status {
        case .active:
            break
        case .pendingDeletion:
            applicationStateService.state = .delete
        case .deleted:
            if UserDefaultsConfig.usersId.isNotEmpty {
                authService.logout(removeData: true) { _ in }
                applicationStateService.state = .auth
            }
        }
    }
    
    private func handleApplicationState(_ applicationState: ApplicationState) {
        self.applicationState = applicationState
        switch applicationState {
        case .initial:
            initialProcess()
        case .login:
            loginProcess()
        case .home:
            homeProcess()
        case .auth:
            break
//            windowManager.showAuthWindow()
        case .delete:
            deleteProcess()
        }
    }
    
    // MARK: - Process
    
    private func initialProcess() {
        if UserDefaultsConfig.usersId.isNotEmpty {
            applicationStateService.state = .login
        } else {
            applicationStateService.state = .auth
        }
    }
    
    private func loginProcess() {
        let userId = UserDefaultsConfig.usersId
        guard userId.isNotEmpty else {
            applicationStateService.state = .auth
            return
        }
        
//        windowManager.showLaunchWindow()
        
        Task { @MainActor in
            do {
                let seed = try seedService.obtainSeed()
                try await authService.walletRecovery(mnemonic: seed)
                let result = try await authService.selectAccount(id: userId)
                
                switch result {
                case .active:
                    applicationStateService.state = .home
                case .pendingDeletion:
                    applicationStateService.state = .delete
                case .deleted:
                    applicationStateService.state = .auth
                }
            } catch {
                applicationStateService.state = .auth
            }
        }
    }
    
    private func homeProcess() {
//        windowManager.showHomeWindow()
        
//        let url = connectionOptions?
//            .urlContexts
//            .map(\.url)
//            .first
//
//        if let url {
//            handleDeeplink(url: url)
//        }
        
//        connectionOptions = nil
    }
    
    private func deleteProcess() {
        guard case let .pendingDeletion(deadline) = accountManager.account.status else {
            applicationStateService.state = .initial
            return
        }
//        windowManager.showDeletedAccountWindow(deadline: deadline)
    }
    
    private func handleFileLimitReachedError() {
        toastPresenter.show(message: Loc.FileStorage.limitError)
    }
}

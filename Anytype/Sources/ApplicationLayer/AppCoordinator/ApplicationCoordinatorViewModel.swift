import SwiftUI
import Combine
import AnytypeCore
import Services

@MainActor
final class ApplicationCoordinatorViewModel: ObservableObject {

    private let authService: AuthServiceProtocol
    private let accountEventHandler: AccountEventHandlerProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let seedService: SeedServiceProtocol
    private let fileErrorEventHandler: FileErrorEventHandlerProtocol
    
    private let authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol
    private let homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol
    private let deleteAccountModuleAssembly: DeleteAccountModuleAssemblyProtocol
    private let initialCoordinatorAssembly: InitialCoordinatorAssemblyProtocol
    private let debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    
    private var authCoordinator: AuthCoordinatorProtocol?

    // MARK: - State
    
    @Published var applicationState: ApplicationState = .initial
    @Published var toastBarData: ToastBarData = .empty
    
    // MARK: - Initializers
    
    init(
        authService: AuthServiceProtocol,
        accountEventHandler: AccountEventHandlerProtocol,
        applicationStateService: ApplicationStateServiceProtocol,
        accountManager: AccountManagerProtocol,
        seedService: SeedServiceProtocol,
        fileErrorEventHandler: FileErrorEventHandlerProtocol,
        authCoordinatorAssembly: AuthCoordinatorAssemblyProtocol,
        homeWidgetsCoordinatorAssembly: HomeWidgetsCoordinatorAssemblyProtocol,
        deleteAccountModuleAssembly: DeleteAccountModuleAssemblyProtocol,
        initialCoordinatorAssembly: InitialCoordinatorAssemblyProtocol,
        debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol
    ) {
        self.authService = authService
        self.accountEventHandler = accountEventHandler
        self.applicationStateService = applicationStateService
        self.accountManager = accountManager
        self.seedService = seedService
        self.fileErrorEventHandler = fileErrorEventHandler
        self.authCoordinatorAssembly = authCoordinatorAssembly
        self.homeWidgetsCoordinatorAssembly = homeWidgetsCoordinatorAssembly
        self.deleteAccountModuleAssembly = deleteAccountModuleAssembly
        self.initialCoordinatorAssembly = initialCoordinatorAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
        self.navigationContext = navigationContext
    }
    
    func onAppear() {
        runAtFirstLaunch()
        startObserve()
    }
    
    func initialView() -> AnyView {
        return initialCoordinatorAssembly.make()
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

    func deleteAccount() -> AnyView? {
        if case let .pendingDeletion(deadline) = accountManager.account.status {
            return deleteAccountModuleAssembly.make(deadline: deadline)
        } else {
            applicationStateService.state = .initial
            return nil
        }

    }
    
    func debugView() -> AnyView {
        debugMenuModuleAssembly.make()
    }

    // MARK: - Subscription

    private func startObserve() {
        Task { @MainActor [weak self, applicationStateService] in
            for await state in applicationStateService.statePublisher.removeDuplicates().values {
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
        case .login:
            loginProcess()
        case .home:
            break
        case .auth:
            break
        case .initial, .delete:
            // For legacy ios untill 16.4
            navigationContext.dismissAllPresented(animated: true)
        }
    }
    
    // MARK: - Process

    private func loginProcess() {
        let userId = UserDefaultsConfig.usersId
        guard userId.isNotEmpty else {
            applicationStateService.state = .auth
            return
        }

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

    private func handleFileLimitReachedError() {
        toastBarData = ToastBarData(text: Loc.FileStorage.limitError, showSnackBar: true, messageType: .none)
    }
}

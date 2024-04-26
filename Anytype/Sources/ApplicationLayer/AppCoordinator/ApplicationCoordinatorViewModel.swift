import SwiftUI
import Combine
import AnytypeCore
import Services

@MainActor
final class ApplicationCoordinatorViewModel: ObservableObject {

    @Injected(\.authService)
    private var authService: AuthServiceProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: AccountEventHandlerProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.seedService)
    private var seedService: SeedServiceProtocol
    @Injected(\.fileErrorEventHandler)
    private var fileErrorEventHandler: FileErrorEventHandlerProtocol
    
    private let homeCoordinatorAssembly: HomeCoordinatorAssemblyProtocol
    private let deleteAccountModuleAssembly: DeleteAccountModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    
    private var authCoordinator: AuthCoordinatorProtocol?

    // MARK: - State
    
    @Published var applicationState: ApplicationState = .initial
    @Published var toastBarData: ToastBarData = .empty
    
    // MARK: - Initializers
    
    init(
        homeCoordinatorAssembly: HomeCoordinatorAssemblyProtocol,
        deleteAccountModuleAssembly: DeleteAccountModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol
    ) {
        self.homeCoordinatorAssembly = homeCoordinatorAssembly
        self.deleteAccountModuleAssembly = deleteAccountModuleAssembly
        self.navigationContext = navigationContext
    }
    
    func onAppear() {
        runAtFirstLaunch()
        startObserve()
    }

    func authView() -> AnyView {
        if let authCoordinator {
            return authCoordinator.startFlow()
        }
        
        let coordinator = AuthCoordinator(
            joinFlowCoordinator: JoinFlowCoordinator(),
            loginFlowCoordinator: LoginFlowCoordinator()
        )
        self.authCoordinator = coordinator
        return coordinator.startFlow()
    }

    func homeView() -> AnyView {
        return homeCoordinatorAssembly.make()
    }

    func deleteAccount() -> AnyView? {
        if case let .pendingDeletion(deadline) = accountManager.account.status {
            return deleteAccountModuleAssembly.make(deadline: deadline)
        } else {
            applicationStateService.state = .initial
            return nil
        }

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
                await self.handleAccountStatus(status)
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

    private func handleAccountStatus(_ status: AccountStatus) async {
        switch status {
        case .active:
            break
        case .pendingDeletion:
            applicationStateService.state = .delete
        case .deleted:
            if UserDefaultsConfig.usersId.isNotEmpty {
                try? await authService.logout(removeData: true)
                applicationStateService.state = .auth
            }
        }
    }
    
    private func handleApplicationState(_ applicationState: ApplicationState) {
        self.applicationState = applicationState
        switch applicationState {
        case .initial:
            break
        case .login:
            loginProcess()
        case .home:
            break
        case .auth:
            break
        case .delete:
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
                let account = try await authService.selectAccount(id: userId)
                
                switch account.status {
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

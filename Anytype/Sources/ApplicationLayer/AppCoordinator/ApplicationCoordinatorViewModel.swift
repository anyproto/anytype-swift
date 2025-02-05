import SwiftUI
import Combine
import AnytypeCore
import Services

@MainActor
final class ApplicationCoordinatorViewModel: ObservableObject {

    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: any AccountEventHandlerProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.fileErrorEventHandler)
    private var fileErrorEventHandler: any FileErrorEventHandlerProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    private var authCoordinator: (any AuthCoordinatorProtocol)?
    private var dismissAllPresented: DismissAllPresented?
    
    // MARK: - State
    
    @Published var applicationState: ApplicationState = .initial
    @Published var toastBarData: ToastBarData = .empty
    @Published var migrationData: MigrationModuleData?
    
    // MARK: - Initializers

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

    func deleteAccount() -> AnyView? {
        if case let .pendingDeletion(deadline) = accountManager.account.status {
            return DeletedAccountView(deadline: deadline).eraseToAnyView()
        } else {
            applicationStateService.state = .initial
            return nil
        }

    }
    
    func setDismissAllPresented(dismissAllPresented: DismissAllPresented) {
        self.dismissAllPresented = dismissAllPresented
    }
    
    func startAppStateHandler() async {
        for await state in applicationStateService.statePublisher.removeDuplicates().values {
            await handleApplicationState(state)
        }
    }
    
    func startAccountStateHandler() async {
        for await status in accountEventHandler.accountStatusPublisher.values {
            await handleAccountStatus(status)
        }
    }

    func startFileHandler() async {
        for await _ in fileErrorEventHandler.fileLimitReachedPublisher.values {
            handleFileLimitReachedError()
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
            if userDefaults.usersId.isNotEmpty {
                try? await authService.logout(removeData: true)
                applicationStateService.state = .auth
            }
        }
    }
    
    private func handleApplicationState(_ applicationState: ApplicationState) async {
        await dismissAllPresented?(animated: false)
        withAnimation(self.applicationState == .login ? .default : .none) {
            self.applicationState = applicationState
        }
        
        switch applicationState {
        case .initial:
            break
        case .login:
            await loginProcess()
        case .home:
            break
        case .auth:
            break
        case .delete:
            break
        }
    }
    
    // MARK: - Process

    private func loginProcess() async {
        let userId = userDefaults.usersId
        guard userId.isNotEmpty else {
            applicationStateService.state = .auth
            return
        }

        do {
            let seed = try seedService.obtainSeed()
            try await authService.walletRecovery(mnemonic: seed)
            await selectAccount(id: userId)
        } catch {
            applicationStateService.state = .auth
        }
    }
    
    private func selectAccount(id: String) async {
        do {
            let account = try await authService.selectAccount(id: id)
            
            switch account.status {
            case .active:
                applicationStateService.state = .home
            case .pendingDeletion:
                applicationStateService.state = .delete
            case .deleted:
                applicationStateService.state = .auth
            }
        } catch SelectAccountError.accountStoreNotMigrated {
            migrationData = MigrationModuleData(
                id: id,
                onFinish: { [weak self] in
                    await self?.selectAccount(id: id)
                }
            )
        } catch {
            applicationStateService.state = .auth
        }
    }

    private func handleFileLimitReachedError() {
        toastBarData = ToastBarData(text: Loc.FileStorage.limitError, showSnackBar: true, messageType: .none)
    }
}

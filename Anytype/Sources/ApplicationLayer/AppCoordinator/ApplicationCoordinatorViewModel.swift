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
    
    private var authCoordinator: AuthCoordinatorProtocol?
    private var dismissAllPresented: DismissAllPresented?
    
    // MARK: - State
    
    @Published var applicationState: ApplicationState = .initial
    @Published var toastBarData: ToastBarData = .empty
    
    // MARK: - Initializers
    
    func onAppear() {
        runAtFirstLaunch()
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
    
    // MARK: - Private
    
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
    
    private func handleApplicationState(_ applicationState: ApplicationState) async {
        await dismissAllPresented?(animated: false)
        self.applicationState = applicationState
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
        let userId = UserDefaultsConfig.usersId
        guard userId.isNotEmpty else {
            applicationStateService.state = .auth
            return
        }

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

    private func handleFileLimitReachedError() {
        toastBarData = ToastBarData(text: Loc.FileStorage.limitError, showSnackBar: true, messageType: .none)
    }
}

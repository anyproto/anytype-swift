import SwiftUI
@preconcurrency import Combine
import AnytypeCore
import Services

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phrase = ""
    @Published var autofocus = true
    
    @Published var loadingRoute = LoginLoadingRoute.none
    @Published var accountSelectInProgress = false
    
    @Published var showQrCodeView: Bool = false
    @Published var openSettingsURL = false
    @Published var showDebugMenu = false
    @Published var entropy: String = ""
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    @Published var dismiss = false
    @Published var accountId: String?
    @Published var migrationData: MigrationModuleData?
    @Published var secureAlertData: SecureAlertData?
    
    var loginButtonDisabled: Bool {
        phrase.isEmpty || loadingRoute.isKeychainInProgress || loadingRoute.isQRInProgress
    }
    
    var qrButtonDisabled: Bool {
        loadingRoute.isKeychainInProgress || loadingRoute.isLoginInProgress
    }
    
    var keychainButtonDisabled: Bool {
        loadingRoute.isQRInProgress || loadingRoute.isLoginInProgress
    }
    
    var backButtonDisabled: Bool {
        loadingRoute.isLoadingInProgress && !accountSelectInProgress
    }
    
    lazy var canRestoreFromKeychain = (try? seedService.obtainSeed()).isNotNil
    
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: any LocalAuthServiceProtocol
    @Injected(\.cameraPermissionVerifier)
    private var cameraPermissionVerifier: any CameraPermissionVerifierProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: any AccountEventHandlerProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    
    private weak var output: (any LoginFlowOutput)?
    
    init(output: (any LoginFlowOutput)?) {
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logLoginScreenShow()
    }
    
    func onEnterButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .phrase)
        walletRecoverySync(with: phrase, route: .login)
    }
    
    func onScanQRButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .qr)
        Task {
            let isGranted = await cameraPermissionVerifier.cameraIsGranted()
            if isGranted {
                showQrCodeView = true
            } else {
                openSettingsURL = true
            }
        }
    }
    
    func onKeychainButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .keychain)
        Task {
            try await localAuthWithContinuation { [weak self] in
                guard let self else { return }
                let phrase = try seedService.obtainSeed()
                await walletRecovery(with: phrase, route: .keychain)
            }
        }
    }
    
    private func localAuthWithContinuation(_ continuation: @escaping () async throws -> Void) async throws {
        do {
            try await localAuthService.auth(reason: Loc.accessToKeyFromKeychain)
            try await continuation()
        } catch LocalAuthServiceError.passcodeNotSet {
            secureAlertData = SecureAlertData(completion: { proceed in
                guard proceed else { return }
                try await continuation()
            })
        }
    }
    
    func onbackButtonAction() {
        guard accountSelectInProgress else {
            dismiss.toggle()
            return
        }
        accountId = nil
        logout()
    }
    
    private func logout() {
        Task {
            try await authService.logout(removeData: false)
            dismiss.toggle()
        }
    }
    
    func onEntropySet() async {
        guard entropy.isNotEmpty else { return }
        do {
            let phrase = try await authService.mnemonicByEntropy(entropy)
            await walletRecovery(with: phrase, route: .qr)
        } catch {
            errorText = error.localizedDescription
        }
    }
    
    private func walletRecoverySync(with phrase: String, route: LoginLoadingRoute) {
        Task {
            await walletRecovery(with: phrase, route: route)
        }
    }

    private func walletRecovery(with phrase: String, route: LoginLoadingRoute) async {
        do {
            self.phrase = phrase
            loadingRoute = route
            
            try await authService.walletRecovery(mnemonic: phrase.trimmingCharacters(in: .whitespacesAndNewlines))
            try seedService.saveSeed(phrase)
            
            await recoverWalletSuccess()
        } catch {
            recoverWalletError(error)
        }
    }
    
    private func recoverWalletSuccess() async {
        await accountRecover()
    }
    
    private func recoverWalletError(_ error: some Error) {
        stopButtonsLoading()
        errorText = error.localizedDescription
    }
    
    func handleAccountShowEvent() async {
        for await accountId in await accountEventHandler.accountShowPublisher.values {
            self.accountId = accountId
        }
    }
    
    private func accountRecover() async {
        do {
            try await authService.accountRecover()
        } catch {
            stopButtonsLoading()
            errorText = error.localizedDescription
        }
    }
    
    func selectAccount() async {
        guard let accountId else { return }
        defer {
            stopButtonsLoading()
            accountSelectInProgress = false
        }
        do {
            accountSelectInProgress = true
            let account = try await authService.selectAccount(id: accountId)
            
            switch account.status {
            case .active:
                applicationStateService.state = .home
            case .pendingDeletion:
                applicationStateService.state = .delete
            case .deleted:
                errorText = Loc.vaultDeleted
            }
            
            await pushNotificationsPermissionService.registerForRemoteNotificationsIfNeeded()
        } catch is CancellationError {
            // Ignore cancellations
        } catch SelectAccountError.accountLoadIsCanceled {
            // Ignore load cancellation
        } catch SelectAccountError.accountIsDeleted {
            errorText = Loc.vaultDeleted
        } catch SelectAccountError.failedToFetchRemoteNodeHasIncompatibleProtoVersion {
            errorText = Loc.Vault.Select.Incompatible.Version.Error.text
        } catch SelectAccountError.accountStoreNotMigrated {
            migrationData = MigrationModuleData(
                id: accountId,
                onFinish: { [weak self] in
                    await self?.selectAccount()
                }
            )
        } catch {
            errorText = Loc.selectVaultError
        }
    }
    
    private func stopButtonsLoading() {
        loadingRoute = .none
    }
}

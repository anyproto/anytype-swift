import SwiftUI
import Combine
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
    @Published var entropy: String = "" {
        didSet {
            onEntropySet()
        }
    }
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    @Published var dismiss = false
    
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
    private var authService: AuthServiceProtocol
    @Injected(\.seedService)
    private var seedService: SeedServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: LocalAuthServiceProtocol
    @Injected(\.cameraPermissionVerifier)
    private var cameraPermissionVerifier: CameraPermissionVerifierProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: AccountEventHandlerProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    private weak var output: LoginFlowOutput?
    
    private var selectAccountTask: Task<(), any Error>?
    private var subscriptions = [AnyCancellable]()
    
    init(output: LoginFlowOutput?) {
        self.output = output
        
        self.handleAccountShowEvent()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logLoginScreenShow()
    }
    
    func onSettingsTap() {
        output?.onSettingsAction()
    }
    
    func onEnterButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .phrase)
        walletRecovery(with: phrase, route: .login)
    }
    
    func onScanQRButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .qr)
        cameraPermissionVerifier.cameraPermission
            .receiveOnMain()
            .sink { [weak self] isGranted in
                guard let self else { return }
                if isGranted {
                    showQrCodeView = true
                } else {
                    openSettingsURL = true
                }
            }
            .store(in: &subscriptions)
    }
    
    func onKeychainButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .keychain)
        restoreFromkeychain()
    }
    
    func onbackButtonAction() {
        guard accountSelectInProgress else {
            dismiss.toggle()
            return
        }
        selectAccountTask?.cancel()
        logout()
    }
    
    private func logout() {
        Task {
            try await authService.logout(removeData: false)
            dismiss.toggle()
        }
    }
    
    private func onEntropySet() {
        Task {
            do {
                let phrase = try await authService.mnemonicByEntropy(entropy)
                walletRecovery(with: phrase, route: .qr)
            } catch {
                errorText = error.localizedDescription
            }
        }
    }

    private func walletRecovery(with phrase: String, route: LoginLoadingRoute) {
        Task {
            do {
                self.phrase = phrase
                loadingRoute = route
                
                try await authService.walletRecovery(mnemonic: phrase.trimmingCharacters(in: .whitespacesAndNewlines))
                try seedService.saveSeed(phrase)
                
                recoverWalletSuccess()
            } catch {
                recoverWalletError(error)
            }
        }
    }
    
    private func restoreFromkeychain() {
        Task {
            try await localAuthService.auth(reason: Loc.restoreKeyFromKeychain)
            let phrase = try seedService.obtainSeed()
            walletRecovery(with: phrase, route: .keychain)
        }
    }
    
    private func recoverWalletSuccess() {
        accountRecover()
    }
    
    private func recoverWalletError(_ error: Error) {
        stopButtonsLoading()
        errorText = error.localizedDescription
    }
    
    private func handleAccountShowEvent() {
        accountEventHandler.accountShowPublisher
            .sink { [weak self] accountId in
                self?.selectProfile(id: accountId)
            }
            .store(in: &subscriptions)
    }
    
    private func accountRecover() {
        Task {
            do {
                try await authService.accountRecover()
            } catch {
                stopButtonsLoading()
                errorText = error.localizedDescription
            }
        }
    }
    
    private func selectProfile(id: String) {
        selectAccountTask = Task {
            defer {
                stopButtonsLoading()
                accountSelectInProgress = false
            }
            do {
                accountSelectInProgress = true
                let account = try await authService.selectAccount(id: id)
                
                try Task.checkCancellation()
                
                switch account.status {
                case .active:
                    applicationStateService.state = .home
                case .pendingDeletion:
                    applicationStateService.state = .delete
                case .deleted:
                    errorText = Loc.vaultDeleted
                }
            } catch is CancellationError {
                // Ignore cancellations
            } catch SelectAccountError.accountIsDeleted {
                errorText = Loc.vaultDeleted
            } catch SelectAccountError.failedToFetchRemoteNodeHasIncompatibleProtoVersion {
                errorText = Loc.Vault.Select.Incompatible.Version.Error.text
            } catch {
                errorText = Loc.selectVaultError
            }
        }
    }
    
    private func stopButtonsLoading() {
        loadingRoute = .none
    }
}

import SwiftUI
import Combine
import AnytypeCore

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phrase = ""
    @Published var autofocus = true
    
    @Published var loadingRoute = LoginLoadingRoute.none
    
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
    
    var loginButtonDisabled: Bool {
        phrase.isEmpty || loadingRoute.isKeychainInProgress || loadingRoute.isQRInProgress
    }
    
    var qrButtonDisabled: Bool {
        loadingRoute.isKeychainInProgress || loadingRoute.isLoginInProgress
    }
    
    var keychainButtonDisabled: Bool {
        loadingRoute.isQRInProgress || loadingRoute.isLoginInProgress
    }
    
    let canRestoreFromKeychain: Bool
    
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let localAuthService: LocalAuthServiceProtocol
    private let cameraPermissionVerifier: CameraPermissionVerifierProtocol
    private let accountEventHandler: AccountEventHandlerProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private weak var output: LoginFlowOutput?
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol,
        localAuthService: LocalAuthServiceProtocol,
        cameraPermissionVerifier: CameraPermissionVerifierProtocol,
        accountEventHandler: AccountEventHandlerProtocol,
        applicationStateService: ApplicationStateServiceProtocol,
        output: LoginFlowOutput?
    ) {
        self.authService = authService
        self.seedService = seedService
        self.localAuthService = localAuthService
        self.cameraPermissionVerifier = cameraPermissionVerifier
        self.canRestoreFromKeychain = (try? seedService.obtainSeed()).isNotNil
        self.accountEventHandler = accountEventHandler
        self.applicationStateService = applicationStateService
        self.output = output
        
        self.handleAccountShowEvent()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logLoginScreenShow()
    }
    
    func onEnterButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .phrase)
        walletRecovery(with: phrase, route: .login)
    }
    
    func onScanQRButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .qr)
        cameraPermissionVerifier.cameraPermission
            .receiveOnMain()
            .sink { [unowned self] isGranted in
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
        localAuthService.auth(reason: Loc.restoreSecretPhraseFromKeychain) { [unowned self] didComplete in
            guard didComplete,
                  let phrase = try? seedService.obtainSeed() else {
                return
            }
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
        Task {
            defer {
                stopButtonsLoading()
            }
            do {
                let status = try await authService.selectAccount(id: id)
                
                switch status {
                case .active:
                    applicationStateService.state = .home
                case .pendingDeletion:
                    applicationStateService.state = .delete
                case .deleted:
                    errorText = Loc.accountDeleted
                }
            } catch SelectAccountError.failedToFindAccountInfo {
                if FeatureFlags.migrationGuide {
                    output?.onShowMigrationGuideAction()
                } else {
                    errorText = Loc.selectAccountError
                }
            } catch SelectAccountError.accountIsDeleted {
                errorText = Loc.accountDeleted
            } catch SelectAccountError.failedToFetchRemoteNodeHasIncompatibleProtoVersion {
                errorText = Loc.Account.Select.Incompatible.Version.Error.text
            } catch {
                errorText = Loc.selectAccountError
            }
        }
    }
    
    private func stopButtonsLoading() {
        loadingRoute = .none
    }
}

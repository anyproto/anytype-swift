import SwiftUI
@preconcurrency import Combine
import Services

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phrase = ""
    @Published var loadingInProgress = false
    @Published var accountSelectInProgress = false
    @Published var entropy: String = ""
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    @Published var dismiss = false
    @Published var accountId: String?
    @Published var walletRecoveryTaskId: String?
    @Published var logoutTaskId: String?
    
    var backButtonDisabled: Bool {
        loadingInProgress && !accountSelectInProgress
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
    
    private weak var output: (any LoginOutput)?
    
    init(output: (any LoginOutput)?) {
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logLoginScreenShow()
    }
    
    func onEnterButtonAction() {
        AnytypeAnalytics.instance().logClickLogin(button: .phrase)
        walletRecoveryTaskId = UUID().uuidString
    }
    
    func onScanQRButtonAction() async {
        AnytypeAnalytics.instance().logClickLogin(button: .qr)
        let isGranted = await cameraPermissionVerifier.cameraIsGranted()
        if isGranted {
            output?.onOpenQRCodeSelected(
                data: QrCodeScannerData(
                    entropy: Binding(get: { self.entropy }, set: { self.entropy = $0 }),
                    error: Binding(get: { self.errorText }, set: { self.errorText = $0 })
                )
            )
        } else {
            output?.onOpenSettingsSelected()
        }
    }
    
    func onKeychainButtonAction() async throws {
        AnytypeAnalytics.instance().logClickLogin(button: .keychain)
        try await localAuthWithContinuation { [weak self] in
            guard let self else { return }
            phrase = try seedService.obtainSeed()
            await walletRecovery()
        }
    }
    
    func openPublicDebugMenuTap() {
        output?.onOpenPublicDebugMenuSelected()
    }
    
    private func localAuthWithContinuation(_ continuation: @escaping () async throws -> Void) async throws {
        do {
            try await localAuthService.auth(reason: Loc.accessToKeyFromKeychain)
            try await continuation()
        } catch LocalAuthServiceError.passcodeNotSet {
            output?.onOpenSecureAlertSelected(
                data: SecureAlertData(completion: { proceed in
                    guard proceed else { return }
                    try await continuation()
                })
            )
        }
    }
    
    func onbackButtonAction() {
        guard accountSelectInProgress else {
            dismiss.toggle()
            return
        }
        accountId = nil
        logoutAction()
    }
    
    func logoutAction() {
        logoutTaskId = UUID().uuidString
    }
    
    func logout() async {
        defer {
            logoutTaskId = nil
            dismiss.toggle()
        }
        try? await authService.logout(removeData: false)
    }
    
    func onEntropySet() async {
        guard entropy.isNotEmpty else { return }
        do {
            phrase = try await authService.mnemonicByEntropy(entropy)
            await walletRecovery()
        } catch {
            errorText = error.localizedDescription
        }
    }

    func walletRecovery() async {
        do {
            loadingInProgress = true
            
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
        walletRecoveryTaskId = nil
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
            output?.onOpenMigrationSelected(
                data: MigrationModuleData(
                    id: accountId,
                    onFinish: { [weak self] in
                        await self?.selectAccount()
                    }
                )
            )
        } catch {
            errorText = Loc.selectVaultError
        }
    }
    
    private func stopButtonsLoading() {
        loadingInProgress = false
    }
}

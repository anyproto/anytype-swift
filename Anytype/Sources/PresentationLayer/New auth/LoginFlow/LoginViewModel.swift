import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phrase = ""
    @Published var autofocus = true
    @Published var walletRecoveryInProgress = false
    @Published var showQrCodeView: Bool = false
    @Published var openSettingsURL = false
    @Published var entropy: String = "" {
        didSet {
            onEntropySet()
        }
    }
    @Published var error: String?
    
    let canRestoreFromKeychain: Bool
    
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let localAuthService: LocalAuthServiceProtocol
    private let cameraPermissionVerifier: CameraPermissionVerifierProtocol
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol,
        localAuthService: LocalAuthServiceProtocol,
        cameraPermissionVerifier: CameraPermissionVerifierProtocol
    ) {
        self.authService = authService
        self.seedService = seedService
        self.localAuthService = localAuthService
        self.cameraPermissionVerifier = cameraPermissionVerifier
        self.canRestoreFromKeychain = (try? seedService.obtainSeed()).isNotNil
    }
    
    func onNextButtonAction() {
        walletRecovery(with: phrase)
    }
    
    func onScanQRButtonAction() {
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
        restoreFromkeychain()
    }
    
    private func onEntropySet() {
        do {
            let phrase = try authService.mnemonicByEntropy(entropy)
            walletRecovery(with: phrase)
        } catch {}
    }
    
    private func walletRecovery(with phrase: String) {
        Task {
            do {
                self.phrase = phrase
                walletRecoveryInProgress = true
                
                try await authService.walletRecovery(mnemonic: phrase.trimmingCharacters(in: .whitespacesAndNewlines))
                try seedService.saveSeed(phrase)
                
                recoverWalletSuccess()
            } catch {
                recoverWalletError()
            }
        }
    }
    
    private func restoreFromkeychain() {
        localAuthService.auth(reason: Loc.restoreSecretPhraseFromKeychain) { [unowned self] didComplete in
            guard didComplete,
                  let phrase = try? seedService.obtainSeed() else {
                return
            }
            walletRecovery(with: phrase)
        }
    }
    
    private func recoverWalletSuccess() {
        walletRecoveryInProgress = false
    }
    
    private func recoverWalletError() {
        walletRecoveryInProgress = false
    }
}

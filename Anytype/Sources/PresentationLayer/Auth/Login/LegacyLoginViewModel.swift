import SwiftUI
import Combine
import LocalAuthentication

class LegacyLoginViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private lazy var cameraPermissionVerifier = CameraPermissionVerifier()
    private let seedService: SeedServiceProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private let localAuthService: LocalAuthServiceProtocol
    
    @Published var seed: String = ""
    @Published var showQrCodeView: Bool = false
    @Published var openSettingsURL = false
    @Published var error: String? {
        didSet {
            showError = false
            
            if error.isNotNil {
                showError = true
            }
        }
    }
    @Published var showError: Bool = false
    
    @Published var entropy: String = "" {
        didSet {
            onEntropySet()
        }
    }
    @Published var showSelectProfile = false
    @Published var showMigrationGuide = false
    @Published var focusOnTextField = true
    
    let canRestoreFromKeychain: Bool

    private var subscriptions = [AnyCancellable]()

    init(
        seedService: SeedServiceProtocol = ServiceLocator.shared.seedService(),
        applicationStateService: ApplicationStateServiceProtocol,
        localAuthService: LocalAuthServiceProtocol = ServiceLocator.shared.localAuthService()
    ) {
        self.canRestoreFromKeychain = (try? seedService.obtainSeed()).isNotNil
        self.seedService = seedService
        self.applicationStateService = applicationStateService
        self.localAuthService = localAuthService
    }
    
    func onEntropySet() {
        Task { @MainActor in
            do {
                let seed = try await authService.mnemonicByEntropy(entropy)
                self.seed = seed
                recoverWallet()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func recoverWallet() {
        recoverWallet(with: seed)
    }

    func onShowQRCodeTap() {
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

    func restoreFromkeychain() {
        localAuthService.auth(reason: Loc.restoreSecretPhraseFromKeychain) { [weak self] didComplete in
            guard let self, didComplete,
                  let phrase = try? seedService.obtainSeed() else {
                return
            }

            recoverWallet(with: phrase)
        }
    }
    
    @MainActor
    func selectProfileFlow() -> some View {
        let viewModel = SelectProfileViewModel(applicationStateService: applicationStateService, onShowMigrationGuide: { [weak self] in
            self?.focusOnTextField = false
            self?.showSelectProfile = false
            self?.showMigrationGuide = true
        })
        return SelectProfileView(viewModel: viewModel)
    }
    
    func migrationGuideFlow() -> some View {
        return MigrationGuideView()
            .onDisappear { [weak self] in
                self?.focusOnTextField = true
            }
    }

    private func recoverWallet(with string: String) {
        Task { @MainActor in
            do {
                try await authService.walletRecovery(mnemonic: string.trimmingCharacters(in: .whitespacesAndNewlines))
                try seedService.saveSeed(string)
                showSelectProfile = true
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}

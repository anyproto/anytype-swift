import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private lazy var cameraPermissionVerifier = CameraPermissionVerifier()

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

    private var subscriptions = [AnyCancellable]()
    
    func onEntropySet() {
        authService.mnemonicByEntropy(entropy) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.error = error.localizedDescription
            case .success(let seed):
                self?.seed = seed
                self?.recoverWallet()
            }
        }
    }
    
    func recoverWallet() {
        authService.walletRecovery(mnemonic: seed.trimmingCharacters(in: .whitespacesAndNewlines)) { result in
            DispatchQueue.main.async { [weak self] in
                if case .failure(let .recoverWalletError(error)) = result {
                    self?.error = error
                    return
                }
                self?.showSelectProfile = true
            }
        }
    }

    func onShowQRCodeTap() {
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
}

import SwiftUI


class LoginViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private let localRepoService = ServiceLocator.shared.localRepoService()

    @Published var seed: String = ""
    @Published var showQrCodeView: Bool = false
    @Published var error: String? {
        didSet {
            showError = false
            
            if !error.isNil {
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
        authService.walletRecovery(mnemonic: seed, path: localRepoService.middlewareRepoPath) { result in
            if case .failure(let .recoverWalletError(error)) = result {
                self.error = error
                return
            }
            
            DispatchQueue.main.async {
                windowHolder?.startNewRootView(SelectProfileView(viewModel: SelectProfileViewModel()))
            }
        }
    }
}

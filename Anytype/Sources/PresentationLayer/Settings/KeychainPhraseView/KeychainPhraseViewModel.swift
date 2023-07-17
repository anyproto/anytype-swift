import SwiftUI
import LocalAuthentication

class KeychainPhraseViewModel: ObservableObject {
    
    // MARK: - DI

    private let shownInContext: AnalyticsEventsKeychainContext
    private let seedService: SeedServiceProtocol
    private let localAuthService: LocalAuthServiceProtocol

    // MARK: - State
    
    @Published private(set) var recoveryPhrase: String? = nil
    @Published var toastBarData: ToastBarData = .empty
    
    init(
        shownInContext: AnalyticsEventsKeychainContext,
        seedService: SeedServiceProtocol,
        localAuthService: LocalAuthServiceProtocol
    ) {
        self.shownInContext = shownInContext
        self.seedService = seedService
        self.localAuthService = localAuthService
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logKeychainPhraseShow(shownInContext)
    }
    
    func onSeedViewTap() {
        if recoveryPhrase.isNil {
            obtainRecoveryPhrase(onTap: { [weak self] in self?.showToast() })
        }
        
        guard let recoveryPhrase = recoveryPhrase else {
            return
        }
        
        onSuccessfullRecovery(recoveryPhrase: recoveryPhrase, onTap: { [weak self] in self?.showToast() })
    }
    
    // MARK: - Private
    
    private func obtainRecoveryPhrase(onTap: @escaping () -> ()) {
        localAuthService.auth(reason: Loc.accessToSecretPhraseFromKeychain) { [weak self] didComplete in
            guard didComplete,
                  let phrase = try? self?.seedService.obtainSeed() else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                recoveryPhrase = phrase
                onSuccessfullRecovery(recoveryPhrase: phrase, onTap: onTap)
            }
        }
    }
    
    private func onSuccessfullRecovery(recoveryPhrase: String, onTap: () -> ()) {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = recoveryPhrase
        onTap()
    }
    
    private func showToast() {
        toastBarData = ToastBarData(text: Loc.Keychain.recoveryPhraseCopiedToClipboard, showSnackBar: true)
        AnytypeAnalytics.instance().logKeychainPhraseCopy(shownInContext)
    }
}

extension KeychainPhraseViewModel {
    static func makeForPreview() -> KeychainPhraseViewModel {
        KeychainPhraseViewModel(
            shownInContext: .logout,
            seedService: DI.preview.serviceLocator.seedService(),
            localAuthService: DI.preview.serviceLocator.localAuthService()
        )
    }
}

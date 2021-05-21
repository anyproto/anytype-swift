import SwiftUI

class KeychainPhraseViewModel: ObservableObject {
    @Published var recoveryPhrase: String? = nil
    @Published var showSnackbar = false
    
    private let keychainStoreService = ServiceLocator.shared.keychainStoreService()

    func obtainRecoveryPhrase() {
        recoveryPhrase = try? keychainStoreService.obtainSeed(
            for: UserDefaultsConfig.usersIdKey, keychainPassword: .userPresence
        )
    }

    func onSeedViewTap() {
        if recoveryPhrase.isNil {
            obtainRecoveryPhrase()
        }
        
        guard let recoveryPhrase = recoveryPhrase else {
            return
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = recoveryPhrase
        showSnackbar = true
    }
}

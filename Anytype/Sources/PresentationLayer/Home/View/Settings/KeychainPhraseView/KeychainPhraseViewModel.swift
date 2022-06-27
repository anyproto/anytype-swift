import SwiftUI
import LocalAuthentication

class KeychainPhraseViewModel: ObservableObject {
    @Published var recoveryPhrase: String? = nil
    
    private let seedService = ServiceLocator.shared.seedService()

    private func obtainRecoveryPhrase(onTap: @escaping () -> ()) {
        LocalAuth.auth(reason: Loc.accessToSecretPhraseFromKeychain) { [unowned self] didComplete in
            guard didComplete,
                  let phrase = try? seedService.obtainSeed() else {
                return
            }
            
            DispatchQueue.main.async {
                recoveryPhrase = phrase
                onSuccessfullRecovery(recoveryPhrase: phrase, onTap: onTap)
            }
        }
    }

    func onSeedViewTap(onTap: @escaping () -> ()) {
        if recoveryPhrase.isNil {
            obtainRecoveryPhrase(onTap: onTap)
        }
        
        guard let recoveryPhrase = recoveryPhrase else {
            return
        }
        
        onSuccessfullRecovery(recoveryPhrase: recoveryPhrase, onTap: onTap)
    }
    
    private func onSuccessfullRecovery(recoveryPhrase: String, onTap: () -> ()) {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = recoveryPhrase
        onTap()
    }
}

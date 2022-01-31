import SwiftUI
import LocalAuthentication

class KeychainPhraseViewModel: ObservableObject {
    @Published var recoveryPhrase: String? = nil
    
    private let seedService = ServiceLocator.shared.seedService()

    private func obtainRecoveryPhrase(onTap: @escaping () -> ()) {
        let permissionContext = LAContext()
        permissionContext.localizedCancelTitle = "Cancel".localized

        var error: NSError?
        if permissionContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Access to secret phrase from keychain".localized
            permissionContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] didComplete, evaluationError in
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

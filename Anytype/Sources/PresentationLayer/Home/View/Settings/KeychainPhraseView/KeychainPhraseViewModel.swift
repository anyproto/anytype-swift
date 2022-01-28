import SwiftUI
import LocalAuthentication

class KeychainPhraseViewModel: ObservableObject {
    @Published var recoveryPhrase: String? = nil
    
    private let seedService = ServiceLocator.shared.seedService()

    private func obtainRecoveryPhrase() {
        let permissionContext = LAContext()

        var error: NSError?
        if permissionContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Access to secret phrase from keychain".localized
            permissionContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [unowned self] didComplete, evaluationError in
                guard didComplete,
                      let phrase = try? seedService.obtainSeed() else {
                    return
                }
                
                DispatchQueue.main.async {
                    recoveryPhrase = phrase
                }
            }
        }
    }

    func onSeedViewTap(onTap: () -> ()) {
        if recoveryPhrase.isNil {
            obtainRecoveryPhrase()
        }
        
        guard let recoveryPhrase = recoveryPhrase else {
            return
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = recoveryPhrase
        onTap()
    }
}

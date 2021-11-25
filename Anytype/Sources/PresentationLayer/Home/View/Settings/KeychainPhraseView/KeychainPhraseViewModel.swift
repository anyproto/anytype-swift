import SwiftUI

class KeychainPhraseViewModel: ObservableObject {
    @Published var recoveryPhrase: String? = nil
    
    private let seedService = ServiceLocator.shared.seedService()

    func obtainRecoveryPhrase() {
        recoveryPhrase = try? seedService.obtainSeed()
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

import SwiftUI

class KeychainPhraseViewModel: ObservableObject {
    private let keychainStoreService = ServiceLocator.shared.keychainStoreService()

    @Published var recoveryPhrase: String = ""
    @Published var copySeedAction: Void = () {
        didSet {
            copySeed()
        }
    }

    func viewLoaded() {
        let seed = try? keychainStoreService.obtainSeed(for: UserDefaultsConfig.usersIdKey, keychainPassword: .userPresence)
        self.recoveryPhrase = seed ?? ""
    }

    private func copySeed() {
        UIPasteboard.general.string = recoveryPhrase
    }
}

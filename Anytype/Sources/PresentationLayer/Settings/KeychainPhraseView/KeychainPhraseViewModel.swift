import SwiftUI
import LocalAuthentication

@MainActor
class KeychainPhraseViewModel: ObservableObject {
    
    // MARK: - DI

    private let shownInContext: AnalyticsEventsKeychainContext
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: any LocalAuthServiceProtocol

    // MARK: - State
    
    @Published private(set) var recoveryPhrase: String? = nil
    @Published var toastBarData: ToastBarData?
    
    init(shownInContext: AnalyticsEventsKeychainContext) {
        self.shownInContext = shownInContext
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logKeychainPhraseShow(shownInContext)
    }
    
    func onSeedViewTap() {
        Task {
            if recoveryPhrase.isNil {
                try await obtainRecoveryPhrase()
            }
            
            onSuccessfullRecovery()
            showToast()
        }
    }
    
    // MARK: - Private
    
    private func obtainRecoveryPhrase() async throws {
        try await localAuthService.auth(reason: Loc.accessToKeyFromKeychain)
        recoveryPhrase = try seedService.obtainSeed()
    }
    
    private func onSuccessfullRecovery() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = recoveryPhrase
    }
    
    private func showToast() {
        toastBarData = ToastBarData(Loc.Keychain.Key.Copy.Toast.title)
        AnytypeAnalytics.instance().logKeychainPhraseCopy(shownInContext)
    }
}

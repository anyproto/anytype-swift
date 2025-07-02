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
    @Published var secureAlertData: SecureAlertData?
    
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
        }
    }
    
    // MARK: - Private
    
    private func obtainRecoveryPhrase() async throws {
        try await localAuthWithContinuation { [weak self] in
            guard let self else { return }
            try obtainSeed()
            onSuccessfullRecovery()
            showToast()
        }
    }
    
    private func localAuthWithContinuation(_ continuation: @escaping () async throws -> Void) async throws {
        do {
            try await localAuthService.auth(reason: Loc.accessToKeyFromKeychain)
            try await continuation()
        } catch LocalAuthServiceError.passcodeNotSet {
            secureAlertData = SecureAlertData(completion: { proceed in
                Task {
                    guard proceed else { return }
                    try await continuation()
                }
            })
        }
    }
        
    private func obtainSeed() throws {
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

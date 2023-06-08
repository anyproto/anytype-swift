import SwiftUI

final class SignUpData: ObservableObject {
    @Published var userName: String
    @Published var image: UIImage?
    @Published var inviteCode: String
    var mnemonic: String
    
    init(mnemonic: String) {
        userName = ""
        image = nil
        inviteCode = ""

        self.mnemonic = mnemonic
    }
}

final class WaitingOnCreatAccountViewModel: ObservableObject {
    private let applicationStateService: ApplicationStateServiceProtocol
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    
    private let diskStorage = DiskStorage()
    
    private let signUpData: SignUpData
    
    @Published var error: String = ""
    @Published var showError: Bool = false
    
    @Binding var showWaitingView: Bool
    
    init(
        signUpData: SignUpData,
        showWaitingView: Binding<Bool>,
        applicationStateService: ApplicationStateServiceProtocol,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.signUpData = signUpData
        self._showWaitingView = showWaitingView
        self.applicationStateService = applicationStateService
        self.authService = authService
        self.seedService = seedService

    }
    
    func createAccount() {
        Task { @MainActor in
            do {
                try await authService.createAccount(
                    name: signUpData.userName,
                    imagePath: imagePath(),
                    alphaInviteCode: signUpData.inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                try? seedService.saveSeed(signUpData.mnemonic)
                applicationStateService.state = .home
            } catch {
                self.error = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func imagePath() -> String {
        guard let image = signUpData.image else { return "" }
        
        let imageName = "avatar_\(self.signUpData.userName.trimmingCharacters(in: .whitespacesAndNewlines))_\(UUID())"
        return diskStorage.saveImage(imageName: imageName, image: image) ?? ""
    }
    
}

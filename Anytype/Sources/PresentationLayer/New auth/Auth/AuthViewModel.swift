import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var showJoinFlow: Bool = false
    @Published var showSafari: Bool = false
    @Published var opacity: Double = 1
    @Published var creatingAccountInProgress = false
    
    // MARK: - Private
    
    private let state: JoinFlowState
    private let viewControllerProvider: ViewControllerProviderProtocol
    private weak var output: AuthViewModelOutput?
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    
    init(
        state: JoinFlowState,
        viewControllerProvider: ViewControllerProviderProtocol,
        output: AuthViewModelOutput?,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.state = state
        self.viewControllerProvider = viewControllerProvider
        self.output = output
        self.authService = authService
        self.seedService = seedService
    }
    
    // MARK: - Public
    
    func onViewAppear() {
        viewControllerProvider.window?.overrideUserInterfaceStyle = .dark
        changeContentOpacity(false)
    }
    
    func videoUrl() -> URL? {
        guard let url = Bundle.main.url(forResource: "anytype-shader-S", withExtension: "mp4") else {
            return nil
        }
        return url
    }
    
    func onJoinButtonTap() {
        createAccount()
    }
    
    func onJoinAction() -> AnyView? {
        output?.onJoinAction()
    }
    
    func onUrlTapAction(_ url: URL) {
        output?.onUrlAction(url)
    }
    
    private func createAccount() {
        Task { @MainActor in
            do {
                creatingAccountInProgress = true
                
                state.mnemonic = try await authService.createWallet()
                try await authService.createAccount(
                    name: "",
                    imagePath: "",
                    alphaInviteCode: state.inviteCode
                )
                try? seedService.saveSeed(state.mnemonic)
                
                createAccountSuccess()
            } catch {
                createAccountError()
            }
        }
    }
    
    private func createAccountSuccess() {
        creatingAccountInProgress = false
        showJoinFlow.toggle()
        changeContentOpacity(true)
    }
    
    private func createAccountError() {
        creatingAccountInProgress = false
    }
    
    private func changeContentOpacity(_ hide: Bool) {
        withAnimation(.fastSpring) {
            opacity = hide ? 0 : 1
        }
    }
}

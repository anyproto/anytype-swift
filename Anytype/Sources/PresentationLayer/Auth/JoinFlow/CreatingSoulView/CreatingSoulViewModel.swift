import SwiftUI
import Services

@MainActor
final class CreatingSoulViewModel: ObservableObject {

    @Published var profileIcon: Icon?
    @Published var spaceIcon: Icon?
    
    @Published var showProfile = false
    @Published var showSpace = false
    
    let state: JoinFlowState
    var soulName: String {
        accountManager.account.id
    }
    
    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let usecaseService: UsecaseServiceProtocol
    private weak var output: JoinFlowStepOutput?
    
    private var animationInProgress = false
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol,
        usecaseService: UsecaseServiceProtocol
    ) {
        self.state = state
        self.output = output
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.authService = authService
        self.seedService = seedService
        self.usecaseService = usecaseService
        self.createAccount()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .soulCreating)
        AnytypeAnalytics.instance().logScreenOnboarding(step: .spaceCreating)
    }
    
    // MARK: - Create account step
    
    private func createAccount() {
        Task {
            output?.disableBackAction(true)
            do {
                state.mnemonic = try await authService.createWallet()
                let account = try await authService.createAccount(
                    name: "",
                    imagePath: ""
                )
                try await usecaseService.setObjectImportUseCaseToSkip(spaceId: account.info.accountSpaceId)
                try? seedService.saveSeed(state.mnemonic)
                
                createAccountSuccess()
            } catch {
                createAccountError(error)
            }
        }
    }
    
    private func createAccountSuccess() {
        output?.disableBackAction(false)
        setupSubscription()
    }
    
    private func createAccountError(_ error: Error) {
        output?.disableBackAction(false)
        output?.onError(error)
    }
    
    // MARK: - Animation step
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subProfileId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.profileIcon = details.objectIconImage
            self?.animateCreation()
        }
        
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: accountManager.account.info.spaceViewId
        ) { [weak self] details in
            self?.spaceIcon = details.objectIconImage
            self?.animateCreation()
        }
    }
    
    private func animateCreation() {
        guard profileIcon != nil, spaceIcon != nil, !animationInProgress else { return }
        
        animationInProgress = true
        
        let animationTime = 0.5
        let finishAnimationTime = 1.5

        withAnimation(.easeInOut(duration: animationTime).delay(animationTime)) { [weak self] in
            self?.showProfile = true
        }

        withAnimation(.easeInOut(duration: animationTime).speed(0.5).delay(animationTime * 2)) { [weak self] in
            self?.showSpace = true
        }
        
        let totalTime = animationTime * 3 + finishAnimationTime
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) { [weak self] in
            withAnimation {
                self?.output?.onNext()
            }
       }
    }
}

private extension CreatingSoulViewModel {
    private enum Constants {
        static let subProfileId = "CreatingSoulProfile"
        static let subSpaceId = "CreatingSoulSpace"
    }
}

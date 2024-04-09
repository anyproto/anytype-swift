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
    
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: SingleObjectSubscriptionServiceProtocol
    @Injected(\.authService)
    private var authService: AuthServiceProtocol
    @Injected(\.seedService)
    private var seedService: SeedServiceProtocol
    @Injected(\.usecaseService)
    private var usecaseService: UsecaseServiceProtocol
    private weak var output: JoinFlowStepOutput?
    
    private var animationInProgress = false
    private var subProfileId = "CreatingSoulProfile-\(UUID())"
    private var subSpaceId = "CreatingSoulSpace-\(UUID())"
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?
    ) {
        self.state = state
        self.output = output
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
                try await usecaseService.setObjectImportDefaultUseCase(spaceId: account.info.accountSpaceId)
                try? seedService.saveSeed(state.mnemonic)
                
                await createAccountSuccess()
            } catch {
                createAccountError(error)
            }
        }
    }
    
    private func createAccountSuccess() async {
        output?.disableBackAction(false)
        await setupSubscription()
    }
    
    private func createAccountError(_ error: Error) {
        output?.disableBackAction(false)
        output?.onError(error)
    }
    
    // MARK: - Animation step
    
    private func setupSubscription() async {
        await subscriptionService.startSubscription(
            subId: subProfileId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.profileIcon = details.objectIconImage
            self?.animateCreation()
        }
        
        await subscriptionService.startSubscription(
            subId: subSpaceId,
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

import SwiftUI
import Services

@MainActor
final class CreatingSoulViewModel: ObservableObject {

    @Published var profileIcon: ObjectIconImage?
    @Published var spaceIcon: ObjectIconImage?
    
    @Published var showProfile = false
    @Published var showSpace = false
    
    let state: JoinFlowState
    
    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private weak var output: JoinFlowStepOutput?
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol
    ) {
        self.state = state
        self.output = output
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .soulCreating)
        AnytypeAnalytics.instance().logScreenOnboarding(step: .spaceCreating)
    }
    
    func animateCreation() {
        guard profileIcon != nil, spaceIcon != nil else { return }
        
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
    
    func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subProfileId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.profileIcon = details.objectIconImage
            self?.animateCreation()
        }
        
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: accountManager.account.info.workspaceObjectId
        ) { [weak self] details in
            self?.spaceIcon = details.objectIconImage
            self?.animateCreation()
        }
    }
}

private extension CreatingSoulViewModel {
    private enum Constants {
        static let subProfileId = "CreatingSoulProfile"
        static let subSpaceId = "CreatingSoulSpace"
    }
}

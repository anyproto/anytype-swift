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
        
        setupSubscription()
    }
    
    func onFinish() {
        output?.onNext()
    }
    
    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showProfile = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.showSpace = true
            }
        }
    }
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subProfileId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.profileIcon = details.objectIconImage
            self?.startAnimation()
        }
        
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: accountManager.account.info.accountSpaceId
        ) { [weak self] details in
            self?.spaceIcon = details.objectIconImage
        }
    }
}

private extension CreatingSoulViewModel {
    private enum Constants {
        static let subProfileId = "CreatingSoulProfile"
        static let subSpaceId = "CreatingSoulSpace"
    }
}

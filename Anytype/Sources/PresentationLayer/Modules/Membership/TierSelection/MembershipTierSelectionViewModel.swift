import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    
    @Published var state: MembershipTierOwningState = .pending
    
    let userMembership: MembershipStatus
    let tierToDisplay: MembershipTier
    
    let onSuccessfulPurchase: (MembershipTier) -> ()
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    
    init(
        userMembership: MembershipStatus,
        tierToDisplay: MembershipTier,
        onSuccessfulPurchase: @escaping (MembershipTier) -> ()
    ) {
        self.userMembership = userMembership
        self.tierToDisplay = tierToDisplay
        self.onSuccessfulPurchase = onSuccessfulPurchase
    }
    
    func onAppear() async {        
        state = await membershipStatusStorage.owningState(tier: tierToDisplay)
    }
}

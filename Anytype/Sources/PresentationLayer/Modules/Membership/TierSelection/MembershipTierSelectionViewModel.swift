import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    
    @Published var state: MembershipTierOwningState?
    
    let userMembership: MembershipStatus
    let tierToDisplay: MembershipTier
    
    let onSuccessfulPurchase: (MembershipTier) -> ()
    
    @Injected(\.membershipService)
    private var membershipService:any MembershipServiceProtocol
    @Injected(\.membershipMetadataProvider)
    private var membershipMetadataProvider:any MembershipMetadataProviderProtocol
    
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
        state = await membershipMetadataProvider.owningState(tier: tierToDisplay)
    }
}

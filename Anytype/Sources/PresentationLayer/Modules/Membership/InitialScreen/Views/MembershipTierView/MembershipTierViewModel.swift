import Services
import SwiftUI


@MainActor
final class MembershipTierViewModel: ObservableObject {
    
    @Published var state: MembershipTierOwningState = .owned
    @Published var userMembership: MembershipStatus = .empty
    
    let tierToDisplay: MembershipTier
    let onTap: () -> ()
    
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    
    init(
        tierToDisplay: MembershipTier,
        onTap: @escaping () -> Void
    ) {
        self.tierToDisplay = tierToDisplay
        self.onTap = onTap
        
        membershipStatusStorage.status.receiveOnMain().assign(to: &$userMembership)
    }
    
    func updateState() {
        Task {
            state = await membershipStatusStorage.owningState(tier: tierToDisplay)
        }
    }
}

import Services
import SwiftUI


@MainActor
final class MembershipTierViewModel: ObservableObject {
    
    @Published var state: MembershipTierOwningState?
    @Published var userMembership: MembershipStatus = .empty
    
    let tierToDisplay: MembershipTier
    let onTap: () -> ()
    
    @Injected(\.membershipMetadataProvider)
    private var tierMetadataProvider: MembershipMetadataProviderProtocol
    
    init(
        tierToDisplay: MembershipTier,
        onTap: @escaping () -> Void
    ) {
        self.tierToDisplay = tierToDisplay
        self.onTap = onTap
        
        let storage = Container.shared.membershipStatusStorage.resolve()
        storage.statusPublisher.receiveOnMain().assign(to: &$userMembership)
    }
    
    func updateState() {
        Task {
            state = await tierMetadataProvider.owningState(tier: tierToDisplay)
        }
    }
}

import Foundation
import Services


@MainActor
final class MembershipModuleViewModel: ObservableObject { 
    let userTier: MembershipTier?
    private let onTierTap: (MembershipTier) -> ()
    
    init(userTier: MembershipTier?, onTierTap: @escaping (MembershipTier) -> ()) {
        self.userTier = userTier
        self.onTierTap = onTierTap
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
}

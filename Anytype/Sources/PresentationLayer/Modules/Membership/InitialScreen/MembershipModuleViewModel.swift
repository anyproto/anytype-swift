import Foundation
import Services


@MainActor
final class MembershipModuleViewModel: ObservableObject {    
    private let onTierTap: (MembershipTier) -> ()
    
    init(onTierTap: @escaping (MembershipTier) -> ()) {
        self.onTierTap = onTierTap
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
}

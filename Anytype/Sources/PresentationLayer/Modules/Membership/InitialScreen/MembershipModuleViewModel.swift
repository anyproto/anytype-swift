import Foundation
import Services
import Combine


@MainActor
final class MembershipModuleViewModel: ObservableObject {    
    private let onTierTap: (MembershipTierId) -> ()
    
    init(onTierTap: @escaping (MembershipTierId) -> ()) {
        self.onTierTap = onTierTap
    }
    
    func onTierTap(tier: MembershipTierId) {
        onTierTap(tier)
    }
}

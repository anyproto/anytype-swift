import Foundation
import Services
import Combine


@MainActor
final class MembershipModuleViewModel: ObservableObject {
    @Published var userTier: MembershipTier?
    
    private let onTierTap: (MembershipTier) -> ()
    
    init(
        userTierPublisher: AnyPublisher<MembershipTier?, Never>,
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.onTierTap = onTierTap
        userTierPublisher.assign(to: &$userTier)
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
}

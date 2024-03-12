import Foundation
import Services
import Combine


@MainActor
final class MembershipModuleViewModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    
    private let onTierTap: (MembershipTier) -> ()
    
    init(
        userMembershipPublisher: AnyPublisher<MembershipStatus, Never>,
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.onTierTap = onTierTap
        userMembershipPublisher.assign(to: &$userMembership)
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
}

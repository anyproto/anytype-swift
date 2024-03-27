import Foundation
import Services
import Combine


@MainActor
final class MembershipModuleViewModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    
    private let onTierTap: (MembershipTierId) -> ()
    
    init(
        userMembershipPublisher: AnyPublisher<MembershipStatus, Never>,
        onTierTap: @escaping (MembershipTierId) -> ()
    ) {
        self.onTierTap = onTierTap
        userMembershipPublisher.assign(to: &$userMembership)
    }
    
    func onTierTap(tier: MembershipTierId) {
        onTierTap(tier)
    }
}

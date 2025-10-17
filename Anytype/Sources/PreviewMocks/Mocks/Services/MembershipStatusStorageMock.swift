import Services
import Foundation
import Combine


final class MembershipStatusStorageMock: MembershipStatusStorageProtocol {

    nonisolated static let shared = MembershipStatusStorageMock()

    nonisolated init() {}

    @Published var _status: MembershipStatus = .empty
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    var currentStatus: MembershipStatus { _status }

    @Published var _tiers: [MembershipTier] = []
    var tiersPublisher: AnyPublisher<[MembershipTier], Never> { $_tiers.eraseToAnyPublisher() }
    var currentTiers: [MembershipTier] { _tiers }

    func owningState(tier: Services.MembershipTier) -> MembershipTierOwningState {
        .owned(.purchasedElsewhere(.desktop))
    }

    func startSubscription() async {

    }

    func refreshMembership() async {

    }
    
    func stopSubscriptionAndClean() async {
        
    }
}

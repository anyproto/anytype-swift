import Services
import Foundation
import Combine


final class MembershipStatusStorageMock: MembershipStatusStorageProtocol {
    
    nonisolated static let shared = MembershipStatusStorageMock()
    
    nonisolated init() {}
    
    @Published var _status: MembershipStatus = .empty
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    var currentStatus: MembershipStatus { _status }
    
    func owningState(tier: Services.MembershipTier) -> MembershipTierOwningState {
        .owned(.purchasedElsewhere(.desktop))
    }
    
    func startSubscription() async {
        
    }
    
    func stopSubscriptionAndClean() async {
        
    }
}

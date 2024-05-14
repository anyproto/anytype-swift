import Services
import Foundation
import Combine


final class MembershipStatusStorageMock: MembershipStatusStorageProtocol {
    
    static let shared = MembershipStatusStorageMock()
    
    @Published var _status: MembershipStatus = .empty
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    var currentStatus: MembershipStatus { _status }
    
    func owningState(tier: Services.MembershipTier) async -> MembershipTierOwningState {
        .owned
    }
    
    func startSubscription() async {
        
    }
    
    func stopSubscriptionAndClean() async {
        
    }
}

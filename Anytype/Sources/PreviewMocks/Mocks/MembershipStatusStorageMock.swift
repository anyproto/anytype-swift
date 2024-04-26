import Services
import Foundation
import Combine


final class MembershipStatusStorageMock: MembershipStatusStorageProtocol {
    
    static let shared = MembershipStatusStorageMock()
    
    @Published var _status: MembershipStatus = .empty
    var status: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    
    func owningState(tier: Services.MembershipTier) async -> MembershipTierOwningState {
        .owned
    }
    
    func startSubscription() async {
        
    }
    
    func stopSubscriptionAndClean() async {
        
    }
}

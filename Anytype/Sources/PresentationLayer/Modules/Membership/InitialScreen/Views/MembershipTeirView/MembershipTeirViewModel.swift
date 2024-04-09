import Services
import SwiftUI

enum MembershipTeirViewState {
    case owned
    case pending
    case unowned
    
    var isOwned: Bool {
        self == .owned
    }
    
    var isPending: Bool {
        self == .pending
    }
}

@MainActor
final class MembershipTeirViewModel: ObservableObject {
    
    @Published var state: MembershipTeirViewState = .owned
    @Published var userMembership: MembershipStatus = .empty
    
    let tierToDisplay: MembershipTier
    let onTap: () -> ()
    
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    
    init(
        tierToDisplay: MembershipTier,
        onTap: @escaping () -> Void
    ) {
        self.tierToDisplay = tierToDisplay
        self.onTap = onTap
        
        membershipStatusStorage.status.receiveOnMain().assign(to: &$userMembership)
    }
    
    func updateState() {
        if userMembership.tier?.type == tierToDisplay.type {
            if userMembership.status == .active {
                state = .owned
            } else {
                state = .pending
            }
            
            return
        }
        
        // validate AppStore purchase in case middleware is still processing
        if case let .appStore(product) = tierToDisplay.paymentType {
            Task {
                if try await storeKitService.isPurchased(product: product) {
                    self.state = .pending
                }   
            }
        }
        
        state = .unowned
    }
}

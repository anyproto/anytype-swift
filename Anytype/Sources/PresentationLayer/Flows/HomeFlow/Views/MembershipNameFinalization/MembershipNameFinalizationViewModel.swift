import Services
import SwiftUI
import AnytypeCore
import StoreKit


@MainActor
final class MembershipNameFinalizationViewModel: ObservableObject {
    @Published var isNameValid = false
    
    let tier: MembershipTier
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    init(tier: MembershipTier) {
        self.tier = tier
    }
        
    func finalize(name: String) async throws {
        guard isNameValid else { return }
        
        try await membershipService.finalizeMembership(name: name)
    }
}

import Services
import SwiftUI
import AnytypeCore
import StoreKit


@MainActor
@Observable
final class MembershipNameFinalizationViewModel {
    var isNameValid = false

    @ObservationIgnored
    let tier: MembershipTier

    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    
    init(tier: MembershipTier) {
        self.tier = tier
    }
        
    func finalize(name: String) async throws {
        guard isNameValid else { return }
        
        try await membershipService.finalizeMembership(name: name)
    }
}

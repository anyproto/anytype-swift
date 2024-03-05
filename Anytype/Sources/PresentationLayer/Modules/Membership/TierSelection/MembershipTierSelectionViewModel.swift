import SwiftUI
import Services


final class MembershipTierSelectionViewModel: ObservableObject {
    let tier: MembershipTier
    let membershipService: MembershipServiceProtocol
    
    init(tier: MembershipTier, membershipService: MembershipServiceProtocol) {
        self.tier = tier
        self.membershipService = membershipService
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        try await membershipService.getVerificationEmail(email: email, subscribeToNewsletter: subscribeToNewsletter)
    }
}

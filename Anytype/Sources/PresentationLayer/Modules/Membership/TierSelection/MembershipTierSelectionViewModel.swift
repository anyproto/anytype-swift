import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    let tier: MembershipTier
    private let membershipService: MembershipServiceProtocol
    private let showEmailVerification: () -> ()
    
    init(tier: MembershipTier, membershipService: MembershipServiceProtocol, showEmailVerification: @escaping () -> ()) {
        self.tier = tier
        self.membershipService = membershipService
        self.showEmailVerification = showEmailVerification
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        try await membershipService.getVerificationEmail(email: email, subscribeToNewsletter: subscribeToNewsletter)
        showEmailVerification()
    }
}

import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    let tier: MembershipTier
    private let membershipService: MembershipServiceProtocol
    private let showEmailVerification: (EmailVerificationData) -> ()
    
    init(
        tier: MembershipTier,
        membershipService: MembershipServiceProtocol,
        showEmailVerification: @escaping (EmailVerificationData) -> ()
    ) {
        self.tier = tier
        self.membershipService = membershipService
        self.showEmailVerification = showEmailVerification
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        let data = EmailVerificationData(email: email, subscribeToNewsletter: subscribeToNewsletter)
        try await membershipService.getVerificationEmail(data: data)
        showEmailVerification(data)
    }
}

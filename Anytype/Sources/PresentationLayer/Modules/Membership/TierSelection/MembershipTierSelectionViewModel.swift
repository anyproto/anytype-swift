import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    
    let tierToDisplay: MembershipTier
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    private let showEmailVerification: (EmailVerificationData) -> ()
    
    init(
        tierToDisplay: MembershipTier,
        showEmailVerification: @escaping (EmailVerificationData) -> ()
    ) {
        self.tierToDisplay = tierToDisplay
        self.showEmailVerification = showEmailVerification
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        let data = EmailVerificationData(email: email, subscribeToNewsletter: subscribeToNewsletter)
        try await membershipService.getVerificationEmail(data: data)
        showEmailVerification(data)
    }
}

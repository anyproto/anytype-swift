import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    
    let userMembership: MembershipStatus
    let tierToDisplay: MembershipTier
    
    let onSuccessfulPurchase: (MembershipTier) -> ()
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    private let showEmailVerification: (EmailVerificationData) -> ()
    
    var tierOwned: Bool {
        userMembership.tier?.type == tierToDisplay.type
    }
    
    init(
        userMembership: MembershipStatus,
        tierToDisplay: MembershipTier,
        showEmailVerification: @escaping (EmailVerificationData) -> (),
        onSuccessfulPurchase: @escaping (MembershipTier) -> ()
    ) {
        self.userMembership = userMembership
        self.tierToDisplay = tierToDisplay
        self.showEmailVerification = showEmailVerification
        self.onSuccessfulPurchase = onSuccessfulPurchase
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        let data = EmailVerificationData(email: email, subscribeToNewsletter: subscribeToNewsletter, tier: tierToDisplay)
        try await membershipService.getVerificationEmail(data: data)
        showEmailVerification(data)
    }
}

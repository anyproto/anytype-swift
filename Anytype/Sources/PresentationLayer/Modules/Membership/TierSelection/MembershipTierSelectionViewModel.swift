import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    
    @Published var userTier: MembershipTier?
    let tierToDisplay: MembershipTier
    
    private let membershipService: MembershipServiceProtocol
    private let showEmailVerification: (EmailVerificationData) -> ()
    
    init(
        tierToDisplay: MembershipTier,
        membershipService: MembershipServiceProtocol,
        showEmailVerification: @escaping (EmailVerificationData) -> ()
    ) {
        self.tierToDisplay = tierToDisplay
        self.membershipService = membershipService
        self.showEmailVerification = showEmailVerification
    }
    
    func onAppear() {
        Task {
            userTier = try await membershipService.getStatus()
        }
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        let data = EmailVerificationData(email: email, subscribeToNewsletter: subscribeToNewsletter)
        try await membershipService.getVerificationEmail(data: data)
        showEmailVerification(data)
    }
}

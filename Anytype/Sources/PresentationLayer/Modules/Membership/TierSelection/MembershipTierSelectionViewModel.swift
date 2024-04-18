import SwiftUI
import Services


@MainActor
final class MembershipTierSelectionViewModel: ObservableObject {
    
    @Published var state: MembershipTierOwningState = .owned
    
    let userMembership: MembershipStatus
    let tierToDisplay: MembershipTier
    
    let onSuccessfulPurchase: (MembershipTier) -> ()
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    
    private let showEmailVerification: (EmailVerificationData) -> ()
    
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
    
    func onAppear() async {
        state = await membershipStatusStorage.owningState(tier: tierToDisplay)
    }
    
    func getVerificationEmail(email: String, subscribeToNewsletter: Bool) async throws {
        let data = EmailVerificationData(email: email, subscribeToNewsletter: subscribeToNewsletter, tier: tierToDisplay)
        try await membershipService.getVerificationEmail(data: data)
        showEmailVerification(data)
    }
}

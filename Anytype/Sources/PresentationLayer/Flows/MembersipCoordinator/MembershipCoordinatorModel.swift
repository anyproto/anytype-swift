import SwiftUI
import Services


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    @Published var tiers: [MembershipTier] = []
    
    @Published var showTiersLoadingError = false
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var emailVerificationData: EmailVerificationData?
    @Published var emailUrl: URL?
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    init() {
        membershipStatusStorage.status.assign(to: &$userMembership)
        loadTiers()
    }
    
    func onTierSelected(tier: MembershipTier) {
        switch tier.type {
        case .custom:
            let mailLink = MailUrl(
                to: "support@anytype.io",
                subject: Loc.Membership.CustomTierEmail.subject(accountManager.account.id),
                body: ""
            )
            emailUrl = mailLink.url
            
        case .explorer, .builder, .coCreator:
            showTier = tier
        }
    }
    
    func onEmailDataSubmit(data: EmailVerificationData) {
        emailVerificationData = data
    }
    
    func onSuccessfulValidation(data: EmailVerificationData) {
        emailVerificationData = nil
        showTier = nil
        loadTiers()
        
        // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
        Task {
            try await Task.sleep(seconds: 0.5)
            showSuccess = data.tier
        }
    }
    
    func loadTiers() {
        Task {
            do {
                tiers = try await membershipService.getTiers()
                showTiersLoadingError = false
            } catch {
                showTiersLoadingError = true
            }
        }
    }
}

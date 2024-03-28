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
        loadTiers(noCache: false)
    }
    
    func onTierSelected(tier: MembershipTier) {
        switch tier.id {
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
        loadTiers(noCache: true)
        
        // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
        Task {
            try await Task.sleep(seconds: 0.5)
            showSuccess = data.tier
        }
    }
    
    func loadTiers(noCache: Bool) {
        Task {
            do {
                tiers = try await membershipService.getTiers(noCache: noCache)
                showTiersLoadingError = false
            } catch {
                showTiersLoadingError = true
            }
        }
    }
}

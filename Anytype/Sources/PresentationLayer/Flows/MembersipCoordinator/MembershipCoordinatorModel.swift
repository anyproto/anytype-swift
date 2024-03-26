import SwiftUI
import Services


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var emailVerificationData: EmailVerificationData?
    @Published var emailUrl: URL?
    
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    init() {
        membershipStatusStorage.status.assign(to: &$userMembership)
    }
    
    func onTierSelected(tier: MembershipTier) {
        switch tier {
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
    
    func onSuccessfulValidation() {
        emailVerificationData = nil
        showTier = nil
        
        
        // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
        Task {
            try await Task.sleep(seconds: 0.5)
            showSuccess = .explorer
        }
    }
}

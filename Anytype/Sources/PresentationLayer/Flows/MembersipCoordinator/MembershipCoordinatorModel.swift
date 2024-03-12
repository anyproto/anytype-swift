import SwiftUI
import Services


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var emailVerificationData: EmailVerificationData?
    @Published var emailUrl: URL?
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    func onAppear() {
        updateStatus()
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
        updateStatus()
        
        emailVerificationData = nil
        showTier = nil
        
        
        // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
        Task {
            try await Task.sleep(seconds: 0.5)
            showSuccess = .explorer
        }
    }
    
    private func updateStatus() {
        Task {
            userMembership = try await membershipService.getStatus()
        }
    }
}

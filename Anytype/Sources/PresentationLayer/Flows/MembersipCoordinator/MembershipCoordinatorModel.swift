import SwiftUI
import Services


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var userTier: MembershipTier?
    
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var emailVerificationData: EmailVerificationData?
    @Published var emailUrl: URL?
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    func onAppear() {
        Task {
            userTier = try await membershipService.getStatus()
        }
    }
    
    func onTierSelected(tier: MembershipTier) {
        switch tier {
        case .custom:
            // TODO
            let mailLink = MailUrl(
                to: "hello@anytype.io",
                subject: "Subject",
                body: "Body"
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
        userTier = .explorer
        
        // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
        Task {
            try await Task.sleep(seconds: 0.5)
            showSuccess = .explorer
        }
    }
}

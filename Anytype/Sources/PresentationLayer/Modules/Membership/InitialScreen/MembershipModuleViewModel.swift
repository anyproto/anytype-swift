import Foundation
import Services


@MainActor
final class MembershipModuleViewModel: ObservableObject {
    @Published var tier: MembershipTier?
    
    private let membershipService: MembershipServiceProtocol
    private let urlOpener: URLOpenerProtocol
    private let onTierTap: (MembershipTier) -> ()
    
    init(
        membershipService: MembershipServiceProtocol,
        urlOpener: URLOpenerProtocol,
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.membershipService = membershipService
        self.urlOpener = urlOpener
        self.onTierTap = onTierTap
    }
    
    func updateCurrentTier() {
        Task {
            tier = try await membershipService.getStatus()
        }
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
        
    func onLegalDetailsTap() {
        urlOpener.openUrl(URL(string: "https://anytype.io/pricing")!, presentationStyle: .pageSheet)
    }
    
    func onLegalPrivacyTap() {
        urlOpener.openUrl(URL(string: "https://anytype.io/app_privacy")!, presentationStyle: .pageSheet)
    }
    
    func onLegalTermsTap() {
        urlOpener.openUrl(URL(string: "https://anytype.io/terms_of_use")!, presentationStyle: .pageSheet)
    }
    
    func onLetUsKnowTap() {
        let mailLink = MailUrl(
            to: "license@anytype.io",
            subject: Loc.Membership.Email.subject,
            body: Loc.Membership.Email.body
        )
        guard let mailUrl = mailLink.url else { return }
        urlOpener.openUrl(mailUrl, presentationStyle: .pageSheet)
    }
}

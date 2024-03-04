import Foundation

final class MembershipModuleViewModel: ObservableObject {
    private let urlOpener: URLOpenerProtocol
    
    init(urlOpener: URLOpenerProtocol) {
        self.urlOpener = urlOpener
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

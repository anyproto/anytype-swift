import Foundation

@MainActor
protocol MailUrlBuilderProtocol {
    func membershipUpgrateUrl() -> URL?
}

final class MailUrlBuilder: MailUrlBuilderProtocol {
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    
    nonisolated init() { }
    
    func membershipUpgrateUrl() -> URL? {
        let globalName = accountParticipantsStorage.participants.first?.globalName ?? ""
        let globalNameOrAccountId = globalName.isNotEmpty ? globalName : accountManager.account.id
        
        return MailUrl(
            to: AboutApp.membershipUpgradeMailTo,
            subject: "\(Loc.upgrade) \(globalNameOrAccountId)",
            body: Loc.Membership.Email.body
        ).url
    }
}

extension Container {
    var mailUrlBuilder: Factory<MailUrlBuilderProtocol> {
        self { MailUrlBuilder() }.shared
    }
}

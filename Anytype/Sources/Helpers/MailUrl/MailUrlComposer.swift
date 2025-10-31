import Foundation

@MainActor
protocol MailUrlBuilderProtocol {
    func membershipUpgrateUrl() -> URL?
}

final class MailUrlBuilder: MailUrlBuilderProtocol {
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.participantsStorage)
    private var accountParticipantsStorage: any ParticipantsStorageProtocol
    
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
    var mailUrlBuilder: Factory<any MailUrlBuilderProtocol> {
        self { MailUrlBuilder() }.shared
    }
}

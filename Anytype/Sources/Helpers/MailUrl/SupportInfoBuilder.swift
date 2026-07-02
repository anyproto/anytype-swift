import Foundation
import AnytypeCore
import UIKit
import DeviceKit

// Single source of truth for support diagnostics: the technical/full info blocks
// and the prefilled support `mailto:` URL. Both Settings > About and the membership
// "Ask a question" entry point compose the same body so support receives full
// diagnostic info regardless of where the mail was started.
protocol SupportInfoBuilderProtocol: AnyObject, Sendable {
    // App/account technical info (no device/OS). Shown as copyable tech info.
    func technicalInfo() async -> String
    // technicalInfo plus device model and OS version.
    func fullInfo() async -> String
    // A `mailto:` URL to support prefilled with subject + fullInfo body.
    func supportMailUrl() async -> URL?
}

final class SupportInfoBuilder: SupportInfoBuilderProtocol {

    private let middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol = Container.shared.middlewareConfigurationProvider()
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()

    func technicalInfo() async -> String {
        let libraryVersion = try? await middlewareConfigurationProvider.libraryVersion()

        return [
            Loc.About.appVersion(MetadataProvider.appVersion ?? ""),
            Loc.About.buildNumber(MetadataProvider.buildNumber ?? ""),
            Loc.About.library(libraryVersion ?? ""),
            Loc.About.anytypeId(accountManager.account.id),
            Loc.About.deviceId(accountManager.account.info.deviceId),
            Loc.About.analyticsId(accountManager.account.info.analyticsId)
        ].joined(separator: "\n")
    }

    func fullInfo() async -> String {
        await [
            Loc.About.device(Device.current.safeDescription),
            Loc.About.osVersion(UIDevice.current.systemVersion),
            technicalInfo()
        ].joined(separator: "\n")
    }

    func supportMailUrl() async -> URL? {
        let mailLink = await MailUrl(
            to: AboutApp.supportMailTo,
            subject: Loc.About.Mail.subject(accountManager.account.id),
            body: Loc.About.Mail.body(fullInfo())
        )
        return mailLink.url
    }
}

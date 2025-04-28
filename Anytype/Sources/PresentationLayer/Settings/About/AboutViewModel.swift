import Foundation
import AnytypeCore
import UIKit
import DeviceKit
import AudioToolbox

@MainActor
final class AboutViewModel: ObservableObject {
    
    // MARK: - DI
    @Injected(\.middlewareConfigurationProvider)
    private var middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    private weak var output: (any AboutModuleOutput)?
    
    private var appVersion: String? = MetadataProvider.appVersion
    private var buildNumber: String? = MetadataProvider.buildNumber
    
    // MARK: - State
    
    @Published var info: String = ""
    @Published var snackBarData: ToastBarData?
    @Published var safariUrl: URL?
    @Published var openUrl: URL?
    
    init(output: (any AboutModuleOutput)?) {
        self.output = output
        setupView()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logMenuHelp()
    }
    
    func onWhatsNewTap() {
        AnytypeAnalytics.instance().logWhatsNew()
        handleUrl(string: AboutApp.whatsNewLink)
    }
    
    func onCommunityTap() {
        AnytypeAnalytics.instance().logAnytypeCommunity()
        handleUrl(string: AboutApp.communityLink)
    }
    
    func onHelpTap() {
        AnytypeAnalytics.instance().logHelpAndTutorials()
        handleUrl(string: AboutApp.helpLink)
    }
    
    func onContactTap() {
        AnytypeAnalytics.instance().logContactUs()
        let mailLink = MailUrl(
            to: AboutApp.supportMailTo,
            subject: Loc.About.Mail.subject(accountManager.account.id),
            body: Loc.About.Mail.body(fullInfo())
        )
        openUrl = mailLink.url
    }
    
    func onTermOfUseTap() {
        AnytypeAnalytics.instance().logTermsOfUse()
        handleUrl(string: AboutApp.termsLink)
    }
    
    func onPrivacyPolicyTap() {
        AnytypeAnalytics.instance().logPrivacyPolicy()
        handleUrl(string: AboutApp.privacyPolicyLink)
    }
    
    func onInfoTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = fullInfo()
        snackBarData = ToastBarData(Loc.copiedToClipboard(Loc.About.techInfo))
    }
    
    func onDebugMenuTap() {
        AudioServicesPlaySystemSound(1109)
        output?.onDebugMenuForAboutSelected()
    }
    
    // MARK: - Private
    
    private func setupView() {
        Task { @MainActor in
            let libraryVersion = try? await middlewareConfigurationProvider.libraryVersion()
            
            info = [
                Loc.About.appVersion(appVersion ?? ""),
                Loc.About.buildNumber(buildNumber ?? ""),
                Loc.About.library(libraryVersion ?? ""),
                Loc.About.anytypeId(accountManager.account.id),
                Loc.About.deviceId(accountManager.account.info.deviceId),
                Loc.About.analyticsId(accountManager.account.info.analyticsId)
            ].joined(separator: "\n")
        }
    }
    
    private func handleUrl(string: String) {
        safariUrl = URL(string: string)
    }
    
    private func fullInfo() -> String {
        return [
            Loc.About.device(Device.current.safeDescription),
            Loc.About.osVersion(UIDevice.current.systemVersion),
            info
        ].joined(separator: "\n")
    }
}

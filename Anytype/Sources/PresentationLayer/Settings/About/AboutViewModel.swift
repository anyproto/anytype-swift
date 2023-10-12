import Foundation
import AnytypeCore
import UIKit
import DeviceKit
import AudioToolbox

@MainActor
final class AboutViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let accountManager: AccountManagerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private weak var output: AboutModuleOutput?
    
    private var appVersion: String? = MetadataProvider.appVersion
    private var buildNumber: String? = MetadataProvider.buildNumber
    
    // MARK: - State
    
    @Published var info: String = ""
    @Published var snackBarData = ToastBarData.empty
    
    init(
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        accountManager: AccountManagerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        output: AboutModuleOutput?
    ) {
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.accountManager = accountManager
        self.activeWorkspaceStorage = activeWorkspaceStorage
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
            to: AboutApp.mailTo,
            subject: Loc.About.Mail.subject(accountManager.account.id),
            body: Loc.About.Mail.body(fullInfo())
        )
        guard let mailLinkString = mailLink.string else { return }
        handleUrl(string: mailLinkString)
    }
    
    func onTermOfUseTap() {
        AnytypeAnalytics.instance().logTermsOfUse()
        handleUrl(string: AboutApp.termsLink)
    }
    
    func onPrivacyPolicyTap() {
        AnytypeAnalytics.instance().logPrivacyPolicy()
        handleUrl(string: AboutApp.privacyLink)
    }
    
    func onInfoTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = fullInfo()
        snackBarData = .init(text: Loc.copiedToClipboard(Loc.About.techInfo), showSnackBar: true)
    }
    
    func onDebugMenuTap() {
        AudioServicesPlaySystemSound(1109)
        output?.onDebugMenuSelected()
    }
    
    // MARK: - Private
    
    private func setupView() {
        Task { @MainActor in
            let libraryVersion = try? await middlewareConfigurationProvider.libraryVersion()
            
            info = [
                Loc.About.appVersion(appVersion ?? ""),
                Loc.About.buildNumber(buildNumber ?? ""),
                Loc.About.library(libraryVersion ?? ""),
                Loc.About.accountId(accountManager.account.id),
                Loc.About.deviceId(activeWorkspaceStorage.workspaceInfo.deviceId),
                Loc.About.analyticsId(activeWorkspaceStorage.workspaceInfo.analyticsId)
            ].joined(separator: "\n")
        }
    }
    
    private func handleUrl(string: String) {
        guard let url = URL(string: string) else { return }
        output?.onLinkOpen(url: url)
    }
    
    private func fullInfo() -> String {
        return [
            Loc.About.device(Device.current.safeDescription),
            Loc.About.osVersion(UIDevice.current.systemVersion),
            info
        ].joined(separator: "\n")
    }
}

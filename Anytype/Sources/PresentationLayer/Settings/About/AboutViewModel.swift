import Foundation
import AnytypeCore
import UIKit
import AudioToolbox

@MainActor
@Observable
final class AboutViewModel {

    // MARK: - DI

    @ObservationIgnored @Injected(\.supportInfoBuilder)
    private var supportInfoBuilder: any SupportInfoBuilderProtocol
    @ObservationIgnored
    private weak var output: (any AboutModuleOutput)?

    // MARK: - State

    var info: String = ""
    var snackBarData: ToastBarData?
    var safariUrl: URL?
    var openUrl: URL?
    
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
        Task {
            openUrl = await supportInfoBuilder.supportMailUrl()
        }
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
        Task {
            UIPasteboard.general.string = await supportInfoBuilder.fullInfo()
            snackBarData = ToastBarData(Loc.copiedToClipboard(Loc.About.techInfo))
        }
    }
    
    func onDebugMenuTap() {
        AudioServicesPlaySystemSound(1109)
        output?.onDebugMenuForAboutSelected()
    }
    
    // MARK: - Private
    
    private func setupView() {
        Task {
            info = await supportInfoBuilder.technicalInfo()
        }
    }

    private func handleUrl(string: String) {
        safariUrl = URL(string: string)
    }
}

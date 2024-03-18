import SwiftUI

struct AboutView: View {
    
    @StateObject private var model: AboutViewModel
    
    init(output: AboutModuleOutput?) {
        _model = StateObject(wrappedValue: AboutViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.about)
                .onTapGesture(count: 10) {
                    model.onDebugMenuTap()
                }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    helpSection
                    legalSection
                    techSection
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            model.onAppear()
        }
        .snackbar(toastBarData: $model.snackBarData)
    }
    
    @ViewBuilder
    private var helpSection: some View {
        SectionHeaderView(title: Loc.About.helpCommunity)
        SettingsSectionItemView(name: Loc.About.whatsNew, onTap: {
            model.onWhatsNewTap()
        })
        SettingsSectionItemView(name: Loc.About.anytypeCommunity, onTap: {
            model.onCommunityTap()
        })
        SettingsSectionItemView(name: Loc.About.helpTutorials, onTap: {
            model.onHelpTap()
        })
        SettingsSectionItemView(name: Loc.About.contactUs, onTap: {
            model.onContactTap()
        })
    }
    
    @ViewBuilder
    private var legalSection: some View {
        SectionHeaderView(title: Loc.About.legal)
        SettingsSectionItemView(name: Loc.About.termsOfUse, onTap: {
            model.onTermOfUseTap()
        })
        SettingsSectionItemView(name: Loc.About.privacyPolicy, onTap: {
            model.onPrivacyPolicyTap()
        })
    }
    
    @ViewBuilder
    private var techSection: some View {
        SectionHeaderView(title: Loc.About.techInfo)
        AnytypeText(model.info, style: .caption2Regular, color: .Text.secondary)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 36, trailing: 0))
        .onTapGesture {
            model.onInfoTap()
        }
    }
}

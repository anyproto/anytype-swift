import SwiftUI
import AnytypeCore

struct SettingsAccountView: View {
    @StateObject private var model: SettingsAccountViewModel

    init(output: SettingsAccountModuleOutput?) {
        _model = StateObject(wrappedValue: SettingsAccountViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    accessBlock
                    accountBlock
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsAccountAccess()
        }
    }
    
    @ViewBuilder
    private var header: some View {
        DragIndicator()
        TitleView(title: Loc.Settings.accountAndAccess)
    }
    
    @ViewBuilder
    private var accessBlock: some View {
        SectionHeaderView(title: Loc.access)
        SettingsSectionItemView(
            name: Loc.Keychain.recoveryPhrase,
            imageAsset: .Settings.keychainPhrase,
            onTap: { model.onRecoveryPhraseTap() }
        )
    }

    @ViewBuilder
    private var accountBlock: some View {
        SectionHeaderView(title: Loc.account)
        
        SettingsButton(text: Loc.deleteAccount, textColor: .Text.primary) {
            model.onDeleteAccountTap()
        }
        
        SettingsButton(text: Loc.logOut, textColor: .System.red) {
            model.onLogOutTap()
        }
    }
}

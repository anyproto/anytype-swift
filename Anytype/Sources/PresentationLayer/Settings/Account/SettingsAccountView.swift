import SwiftUI
import AnytypeCore

struct SettingsAccountView: View {
    @StateObject private var model: SettingsAccountViewModel

    init(output: (any SettingsAccountModuleOutput)?) {
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
        TitleView(title: Loc.Settings.vaultAndAccess)
    }
    
    @ViewBuilder
    private var accessBlock: some View {
        SectionHeaderView(title: Loc.access)
        SettingsSectionItemView(
            name: Loc.Keychain.key,
            imageAsset: .Settings.keychainPhrase,
            onTap: { model.onRecoveryPhraseTap() }
        )
    }

    @ViewBuilder
    private var accountBlock: some View {
        SectionHeaderView(title: Loc.vault)
        
        SettingsButton(text: Loc.deleteVault, textColor: .Text.primary) {
            model.onDeleteAccountTap()
        }
        
        SettingsButton(text: Loc.logOut, textColor: .Pure.red) {
            model.onLogOutTap()
        }
    }
}

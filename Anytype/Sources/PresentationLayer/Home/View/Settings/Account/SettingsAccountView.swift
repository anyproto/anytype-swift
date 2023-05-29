import SwiftUI
import AnytypeCore

struct SettingsAccountView: View {
    @ObservedObject var model: SettingsAccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileBlock
                    accessBlock
                    if !FeatureFlags.fileStorage {
                        dataBlock
                    }
                    accountBlock
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.accountSettingsShow)
        }
    }
    
    @ViewBuilder
    private var header: some View {
        DragIndicator()
        TitleView(title: FeatureFlags.fileStorage ? Loc.profile : Loc.accountData)
    }
    
    @ViewBuilder
    private var profileBlock: some View {
        SettingsObjectHeader(name: $model.profileName, nameTitle: Loc.name, iconImage: model.profileIcon, onTap: {
            model.onChangeIconTap()
        })
    }
    
    @ViewBuilder
    private var accessBlock: some View {
        SectionHeaderView(title: Loc.access)
        SettingsSectionItemView(
            name: Loc.Keychain.recoveryPhrase,
            imageAsset: .Settings.setKeychainPhrase,
            onTap: { model.onRecoveryPhraseTap() }
        )
    }
    
    @ViewBuilder
    private var dataBlock: some View {
        SectionHeaderView(title: Loc.data)
        SettingsButton(text: Loc.clearFileCache, textColor: .Text.primary) {
            model.onClearTap()
        }
    }

    @ViewBuilder
    private var accountBlock: some View {
        SectionHeaderView(title: Loc.account)
        
        SettingsButton(text: Loc.logOut, textColor: .Text.primary) {
            model.onLogOutTap()
        }
        
        SettingsButton(text: Loc.deleteAccount, textColor: .System.red) {
            model.onDeleteAccountTap()
        }
    }
}

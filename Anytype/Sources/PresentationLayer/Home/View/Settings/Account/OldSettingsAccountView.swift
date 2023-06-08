import SwiftUI
import AnytypeCore

struct OldSettingsAccountView: View {
    @ObservedObject var model: SettingsAccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            accessBlock
            dataBlock
            accountBlock
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.accountSettingsShow)
        }
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText(Loc.accountData, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
        }
    }
    
    private var accessBlock: some View {
        VStack(spacing: 0) {
            section(Loc.access)
            recoveryPhrase
        }
    }
    
    private var recoveryPhrase: some View {
        SettingsSectionItemView(
            name: Loc.Keychain.recoveryPhrase,
            imageAsset: .Settings.setKeychainPhrase,
            onTap: { model.onRecoveryPhraseTap() }
        )
    }
    
    private var dataBlock: some View {
        VStack(spacing: 0) {
            section(Loc.data)
            SettingsButton(text: Loc.clearFileCache, textColor: .Text.primary) {
                model.onClearTap()
            }
        }
    }

    private var accountBlock: some View {
        VStack(spacing: 0) {
            section(Loc.account)
            
            SettingsButton(text: Loc.deleteAccount, textColor: .Text.primary) {
                model.onDeleteAccountTap()
            }
            
            SettingsButton(text: Loc.logOut, textColor: .System.red) {
                model.onLogOutTap()
            }
         }
    }
    
    private func section(_ text: String) -> some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(26)
            HStack {
                AnytypeText(text, style: .caption1Regular, color: .Text.secondary)
                Spacer()
            }
            Spacer.fixedHeight(8)
        }
    }
}

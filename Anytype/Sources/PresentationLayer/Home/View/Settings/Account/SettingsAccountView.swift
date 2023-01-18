import SwiftUI
import AnytypeCore

struct SettingsAccountView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
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
            imageAsset: .settingsSetKeychainPhrase,
            pressed: $model.keychain
        )
        .sheet(isPresented: $model.keychain) {
            if model.loggingOut {
                KeychainPhraseView(shownInContext: .logout)
            } else {
                KeychainPhraseView(shownInContext: .settings)
            }
        }
    }
    
    private var dataBlock: some View {
        VStack(spacing: 0) {
            section(Loc.data)
            SettingsButton(text: Loc.clearFileCache, textColor: .Text.primary) {
                model.clearCacheAlert = true
            }
        }
    }

    private var accountBlock: some View {
        VStack(spacing: 0) {
            section(Loc.account)
            
            SettingsButton(text: Loc.deleteAccount, textColor: .Text.primary) {
                model.accountDeleting = true
            }
            
            SettingsButton(text: Loc.logOut, textColor: .System.red) {
                model.loggingOut = true
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

struct SettingsAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            SettingsAccountView()
        }
    }
}

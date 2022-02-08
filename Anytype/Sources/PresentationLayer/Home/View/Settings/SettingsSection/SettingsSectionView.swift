import SwiftUI
import Amplitude

struct SettingsSectionView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(
                name: "Wallpaper".localized,
                icon: .settings.wallpaper,
                pressed: $viewModel.wallpaperPicker
            )
            .sheet(isPresented: $viewModel.wallpaperPicker) {
                WallpaperPickerView()
            }
            
            SettingsSectionItemView(
                name: "Keychain phrase".localized,
                icon: .settings.keychain,
                pressed: $viewModel.keychain
            )
            .sheet(isPresented: $viewModel.keychain) {
                if viewModel.loggingOut {
                    KeychainPhraseView(shownInContext: .logout)
                } else {
                    KeychainPhraseView(shownInContext: .settings)
                }
            }
            
//            SettingsSectionItemView(
//                name: "Pin code".localized,
//                icon: .settings.pin,
//                pressed: $viewModel.pincode
//            )
            
            SettingsSectionItemView(
                name: "Other settings".localized,
                icon: .settings.other,
                pressed: $viewModel.other
            )
            .onChange(of: viewModel.other) { showOtherSettings in
                if showOtherSettings {
                    Amplitude.instance().logEvent(AmplitudeEventsName.otherSettingsShow)
                }
            }
            
            SettingsSectionItemView(
                name: "About",
                icon: .settings.about,
                pressed: $viewModel.about
            )
            .sheet(isPresented: $viewModel.about) {
                AboutView()
            }
            
            .sheet(isPresented: $viewModel.debugMenu) {
                DebugMenu()
            }
            #if !RELEASE
            SettingsSectionItemView(
                name: "Debug",
                icon: .settings.debug,
                pressed: $viewModel.debugMenu
            )
            #endif
        }
        .padding([.leading, .trailing], 20)
        .background(Color.backgroundSecondary)
        .cornerRadius(12.0)
    }
}


struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView()
            .environmentObject(SettingsViewModel(authService: ServiceLocator.shared.authService()))
            .previewLayout(.sizeThatFits)
    }
}

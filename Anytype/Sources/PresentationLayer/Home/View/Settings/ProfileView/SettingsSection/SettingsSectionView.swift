import SwiftUI

struct SettingsSectionView: View {
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(
                name: "Wallpaper".localized,
                icon: Image.settings.wallpaper,
                comingSoon: true,
                pressed: $viewModel.wallpaper
            )
            
            SettingsSectionItemView(
                name: "Keychain phrase".localized,
                icon: Image.settings.keychain,
                comingSoon: false,
                pressed: $viewModel.keychain
            )
            .sheet(isPresented: $viewModel.keychain) {
                KeychainPhraseView(viewModel: .init())
            }
            
            SettingsSectionItemView(
                name: "Pin code".localized,
                icon: Image.settings.pin,
                comingSoon: true,
                pressed: $viewModel.pincode
            )
            
            SettingsSectionItemView(
                name: "About",
                icon: Image.settings.about,
                comingSoon: false,
                pressed: $viewModel.about
            )
            .sheet(isPresented: $viewModel.about) {
                AboutView()
            }
            
            #if !RELEASE
            SettingsSectionItemView(
                name: "Debug",
                icon: Image.System.lassoAndSparkles,
                comingSoon: false,
                pressed: $viewModel.debugMenu
            )
            .sheet(isPresented: $viewModel.debugMenu) {
                FeatureFlagsView()
            }
            #endif
        }
        .padding([.leading, .trailing], 20)
        .background(Color.background)
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

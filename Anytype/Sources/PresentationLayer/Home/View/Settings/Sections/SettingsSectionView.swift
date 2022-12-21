import SwiftUI

struct SettingsSectionView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            SettingsSectionItemView(
                name: Loc.accountData,
                imageAsset: .settingsAccountAndData,
                pressed: $viewModel.account
            )
            
            SettingsSectionItemView(
                name: Loc.personalization,
                imageAsset: .settingsPersonalization,
                pressed: $viewModel.personalization
            )
            
            SettingsSectionItemView(
                name: Loc.appearance,
                imageAsset: .settingsAppearance,
                pressed: $viewModel.appearance
            )

            SettingsSectionItemView(
                name: Loc.about,
                imageAsset: .settingsAbout,
                pressed: $viewModel.about
            )
            
            .sheet(isPresented: $viewModel.debugMenu) {
                DebugMenu()
            }
            
            #if DEBUG
            SettingsSectionItemView(
                name: "Debug",
                imageAsset: .settingsDebug,
                pressed: $viewModel.debugMenu
            )
            #endif
        }
        .padding([.leading, .trailing], 20)
        .background(Color.BackgroundNew.secondary)
    }
}


struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView()
            .environmentObject(
                SettingsViewModel(
                    authService: ServiceLocator.shared.authService(),
                    windowManager: DI.makeForPreview().coordinatorsDI.windowManager
                )
            )
            .previewLayout(.sizeThatFits)
    }
}

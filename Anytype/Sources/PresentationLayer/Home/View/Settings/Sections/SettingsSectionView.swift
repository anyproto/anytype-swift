import SwiftUI

struct SettingsSectionView: View {

    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            SettingsSectionItemView(
                name: "Account & data".localized,
                icon: .settings.account,
                pressed: $viewModel.account
            )
            
            SettingsSectionItemView(
                name: "Personalization".localized,
                icon: .settings.personalization,
                pressed: $viewModel.personalization
            )
            
            SettingsSectionItemView(
                name: "Appearance".localized,
                icon: .settings.appearance,
                pressed: $viewModel.appearance
            )

            SettingsSectionItemView(
                name: "About".localized,
                icon: .settings.about,
                pressed: $viewModel.about
            )
            
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
    }
}


struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView()
            .environmentObject(SettingsViewModel(authService: ServiceLocator.shared.authService()))
            .previewLayout(.sizeThatFits)
    }
}

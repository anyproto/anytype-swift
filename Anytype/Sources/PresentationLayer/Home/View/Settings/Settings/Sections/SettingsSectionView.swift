import SwiftUI

struct SettingsSectionView: View {

    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            SettingsSectionItemView(
                name: Loc.accountData,
                imageAsset: .Settings.accountAndData,
                onTap: { viewModel.onAccountDataTap() }
            )
            
            SettingsSectionItemView(
                name: Loc.personalization,
                imageAsset: .Settings.personalization,
                onTap: { viewModel.onPersonalizationTap() }
            )
            
            SettingsSectionItemView(
                name: Loc.appearance,
                imageAsset: .Settings.appearance,
                onTap: { viewModel.onAppearanceTap() }
            )

            SettingsSectionItemView(
                name: Loc.about,
                imageAsset: .Settings.about,
                onTap: { viewModel.onAboutTap() }
            )
            
            #if DEBUG
            SettingsSectionItemView(
                name: "Debug",
                imageAsset: .Settings.debug,
                onTap: { viewModel.onDebugMenuTap() }
            )
            #endif
        }
        .padding([.leading, .trailing], 20)
        .background(Color.Background.secondary)
    }
}

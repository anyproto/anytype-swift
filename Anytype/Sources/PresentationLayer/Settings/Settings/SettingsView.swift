import SwiftUI
import AnytypeCore

struct SettingsView: View {
    
    @ObservedObject var model: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Settings.title)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    
                    SectionHeaderView(title: Loc.settings)
                    
                    SettingsSectionItemView(
                        name: FeatureFlags.fileStorage ? Loc.profile : Loc.accountData,
                        iconImage: model.profileIcon,
                        onTap: { model.onAccountDataTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.personalization,
                        imageAsset: .Settings.personalization,
                        onTap: { model.onPersonalizationTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.appearance,
                        imageAsset: .Settings.appearance,
                        onTap: { model.onAppearanceTap() }
                    )
                    
                    if FeatureFlags.fileStorage {
                        SettingsSectionItemView(
                            name: Loc.FileStorage.title,
                            imageAsset: .Settings.fileStorage,
                            onTap: { model.onFileStorageTap() }
                        )
                    }
                    
                    SettingsSectionItemView(
                        name: Loc.about,
                        imageAsset: .Settings.about,
                        onTap: { model.onAboutTap() }
                    )
                    
                    #if DEBUG
                    SettingsSectionItemView(
                        name: "Debug",
                        imageAsset: .Settings.debug,
                        onTap: { model.onDebugMenuTap() }
                    )
                    #endif
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            model.onAppear()
        }
    }
}


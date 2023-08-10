import SwiftUI
import AnytypeCore

struct SettingsView: View {
    
    @ObservedObject var model: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            if FeatureFlags.multiSpaceSettings {
                TitleView(title: Loc.Settings.title)
            } else {
                TitleView(title: Loc.Settings.titleLegacy)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    if FeatureFlags.multiSpaceSettings {
                        SettingsObjectHeader(name: $model.profileName, nameTitle: Loc.name, iconImage: model.profileIcon, onTap: {
                            model.onChangeIconTap()
                        })
                    } else {
                        SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                            model.onChangeIconTap()
                        })
                    }
                    
                    SectionHeaderView(title: Loc.settings)
                    
                    if FeatureFlags.multiSpaceSettings {
                        SettingsSectionItemView(
                            name: Loc.Settings.accountAndAccess,
                            imageAsset: .Settings.keychainPhrase,
                            onTap: { model.onAccountDataTap() }
                        )
                    } else {
                        SettingsSectionItemView(
                            name: Loc.profile,
                            iconImage: model.profileIcon,
                            onTap: { model.onAccountDataTap() }
                        )
                    }
                    
                    if !FeatureFlags.multiSpaceSettings {
                        SettingsSectionItemView(
                            name: Loc.personalization,
                            imageAsset: .Settings.personalization,
                            onTap: { model.onPersonalizationTap() }
                        )
                    }
                    
                    SettingsSectionItemView(
                        name: Loc.appearance,
                        imageAsset: .Settings.appearance,
                        onTap: { model.onAppearanceTap() }
                    )
                    
                    if FeatureFlags.multiSpaceSettings {
                        SettingsSectionItemView(
                            name: Loc.LocalStorage.title,
                            imageAsset: .Settings.fileStorage,
                            onTap: { model.onFileStorageTap() }
                        )
                    } else {
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


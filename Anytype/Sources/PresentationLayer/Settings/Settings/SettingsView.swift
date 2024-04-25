import SwiftUI
import AnytypeCore

struct SettingsView: View {
    
    @ObservedObject var model: SettingsViewModel
    
    init(output: SettingsModuleOutput) {
        _model = ObservedObject(initialValue: SettingsViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Settings.title)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.profileName, nameTitle: Loc.name, iconImage: model.profileIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    
                    SectionHeaderView(title: Loc.settings)
                    
                    SettingsSectionItemView(
                        name: Loc.appearance,
                        imageAsset: .Settings.appearance,
                        onTap: { model.onAppearanceTap() }
                    )
                    
                    
                    if FeatureFlags.multiplayer {
                        SettingsSectionItemView(
                            name: Loc.Spaces.title,
                            imageAsset: .Settings.spaces,
                            onTap: { model.onSpacesTap() }
                        )
                    }
                    
                    SettingsSectionItemView(
                        name: Loc.FileStorage.Local.title,
                        imageAsset: .Settings.fileStorage,
                        onTap: { model.onFileStorageTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.Settings.vaultAndAccess,
                        imageAsset: .Settings.keychainPhrase,
                        onTap: { model.onAccountDataTap() }
                    )
                    
                    if FeatureFlags.membership {
                        SettingsSectionItemView(
                            name: Loc.membership,
                            imageAsset: .Settings.membership,
                            decoration: model.membership.tier.map { .arrow (text: $0.name) } ?? .button(text: Loc.join),
                            onTap: { model.onMembershipTap() }
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


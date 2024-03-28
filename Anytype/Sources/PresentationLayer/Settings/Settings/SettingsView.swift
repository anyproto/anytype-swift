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
                        name: Loc.Settings.accountAndAccess,
                        imageAsset: .Settings.keychainPhrase,
                        onTap: { model.onAccountDataTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.appearance,
                        imageAsset: .Settings.appearance,
                        onTap: { model.onAppearanceTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.FileStorage.Local.title,
                        imageAsset: .Settings.fileStorage,
                        onTap: { model.onFileStorageTap() }
                    )
                    
                    if FeatureFlags.multiplayer {
                        SettingsSectionItemView(
                            name: Loc.Spaces.title,
                            imageAsset: .Settings.spaces,
                            onTap: { model.onSpacesTap() }
                        )
                    }
                    
                    if FeatureFlags.membership {
                        SettingsSectionItemView(
                            name: Loc.membership,
                            imageAsset: .Settings.membership,
                            decoration: model.membership.tierId.map { .arrow (text: $0.title) } ?? .button(text: Loc.join),
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


import SwiftUI
import AnytypeCore

struct SettingsView: View {
    
    @StateObject private var model: SettingsViewModel
    
    init(output: some SettingsModuleOutput) {
        _model = StateObject(wrappedValue: SettingsViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.Settings.title)
                .onTapGesture(count: 5) {
                    model.showDebugMenu.toggle()
                }
            
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
                    
                    SettingsSectionItemView(
                        name: Loc.notifications,
                        imageAsset: .Settings.notifications,
                        decoration: .arrow(needAttention: model.notificationsDenied),
                        onTap: { model.onNotificationsTap() }
                    )
                    
                    SettingsSectionItemView(
                        name: Loc.Spaces.title,
                        imageAsset: .Settings.spaces,
                        onTap: { model.onSpacesTap() }
                    )
                    
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
                    
                    if model.canShowMemberhip {
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
                    
                    #if DEBUG || RELEASE_NIGHTLY
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
        .sheet(isPresented: $model.showDebugMenu) {
            PublicDebugMenuView()
        }
        .task {
            await model.startSubscriptions()
        }
    }
}


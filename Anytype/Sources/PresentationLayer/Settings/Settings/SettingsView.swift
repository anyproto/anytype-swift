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
            TitleView(title: Loc.Settings.title) {
                Menu {
                    if model.canDeleteVault {
                        Button(Loc.deleteVault) { model.onDeleteAccountTap() }
                    }
                    Button(Loc.logOut, role: .destructive) { model.onLogoutTap() }
                } label: {
                    MoreIndicator()
                }
            }
            .onTapGesture(count: 5) {
                model.showDebugMenu.toggle()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    SettingsObjectHeader(name: $model.profileName, nameTitle: Loc.name, iconImage: model.profileIcon, onTap: {
                        model.onChangeIconTap()
                    })
                    
                    SectionHeaderView(title: Loc.application)
                    
                    SettingsSectionItemView(
                        name: Loc.appearance,
                        imageAsset: .Settings.appearance,
                        onTap: { model.onAppearanceTap() }
                    )
                    
                    if FeatureFlags.addNotificationsSettings {
                        SettingsSectionItemView(
                            name: Loc.notifications,
                            imageAsset: .Settings.notifications,
                            decoration: .arrow(needAttention: model.notificationsDenied),
                            onTap: { model.onNotificationsTap() }
                        )
                    }
                    
                    SettingsSectionItemView(
                        name: Loc.loginKey,
                        imageAsset: .Settings.keychainPhrase,
                        onTap: { model.onAccountDataTap() }
                    )
                    
                    if model.canShowMemberhip {
                        SettingsSectionItemView(
                            name: Loc.membership,
                            imageAsset: .Settings.membership,
                            decoration: model.membership.decoration,
                            onTap: { model.onMembershipTap() }
                        )
                    }
                    
                    SectionHeaderView(title: Loc.Settings.dataManagement)
                    
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
                        name: Loc.mySites,
                        imageAsset: .Settings.mySites,
                        onTap: { model.onMySitesTap() }
                    )
                    
                    SectionHeaderView(title: Loc.misc)
                    
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
                    
                    SettingsSectionItemView(
                        name: Loc.logOut,
                        textColor: .Pure.red,
                        imageAsset: .Settings.logOut,
                        onTap: { model.onLogoutTap() }
                    )
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


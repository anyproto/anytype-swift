import SwiftUI
import AnytypeCore

struct SettingsView: View {

    @State private var model: SettingsViewModel

    init(output: some SettingsModuleOutput) {
        _model = State(initialValue: SettingsViewModel(output: output))
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            titleBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    SettingsObjectHeader(
                        name: $model.profileName,
                        nameTitle: Loc.name,
                        iconImage: model.profileIcon,
                        onTap: { model.onChangeIconTap() }
                    )
                    
                    SectionHeaderView(title: Loc.application)
                    
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
                        name: Loc.experimentalFeatures,
                        imageAsset: .X24.experimentalFeatures,
                        onTap: { model.onExterimentapTap() }
                    )
                    
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
        .task {
            await model.startSubscriptions()
        }
        .onChange(of: model.profileName) {
            model.onProfileNameChange()
        }
    }

    private var titleBar: some View {
        HStack {
            Spacer()

            AnyNameBadgeView(
                state: model.anyNameBadgeState,
                onTap: { model.onAnyIdBadgeTap() }
            )

            Spacer()
        }
        .overlay(alignment: .leading) {
            Button {
                model.onQRCodeTap()
            } label: {
                Image(asset: .X24.qrCode)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: 24, height: 24)
            }
            .padding(.leading, 12)
        }
        .overlay(alignment: .trailing) {
            Menu {
                if model.canDeleteVault {
                    Button(Loc.deleteVault) { model.onDeleteAccountTap() }
                }
                Button(Loc.logOut, role: .destructive) { model.onLogoutTap() }
            } label: {
                MoreIndicator()
            }
            .padding(.trailing, 12)
        }
        .frame(height: 48)
    }
}


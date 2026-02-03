import Foundation
import SwiftUI
import AnytypeCore
import Services

struct SpaceSettingsView: View {

    @State private var model: SpaceSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(workspaceInfo: AccountInfo, output: (any SpaceSettingsModuleOutput)?) {
        _model = State(initialValue: SpaceSettingsViewModel(workspaceInfo: workspaceInfo, output: output))
    }

    var body: some View {
        content
            .background(backgroundView)
            .homeBottomPanelHidden(true)
            .onAppear {
                model.onAppear()
            }
            .task {
                await model.startSubscriptions()
            }
            .onChange(of: model.dismiss) {
                dismiss()
            }

            .sheet(item: $model.shareInviteLink) { link in
                ActivityView(activityItems: [link])
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)

            .sheet(item: $model.showIconPickerSpaceId) {
                SpaceObjectIconPickerView(spaceId: $0.value)
            }
            .sheet(item: $model.editingData) {
                SettingsInfoEditingView($0)
            }
            .anytypeSheet(item: $model.qrInviteLink) {
                QrCodeView(title: Loc.SpaceShare.Qr.title, data: $0.absoluteString, analyticsType: .inviteSpace, route: .settingsSpace)
            }
            .anytypeSheet(isPresented: $model.showSpaceDeleteAlert) {
                SpaceDeleteAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showSpaceLeaveAlert) {
                SpaceLeaveAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showInfoView) {
                SpaceSettingsInfoView(info: model.info)
            }
            .snackbar(toastBarData: $model.snackBarData)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if model.isOneToOne {
            DashboardWallpaper(wallpaper: model.wallpaper, spaceIcon: model.spaceIcon)
        } else {
            Color.VeryLight.grey.ignoresSafeArea()
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(NavigationHeaderConstants.height)
                spaceDetails
                sharing
                collaboration
                contentModel
                preferences
                dataManagement
                misc
            }
        }
        .padding(.horizontal, 20)
        .overlay(alignment: .top) {
            header
        }
    }

    private var header: some View {
        NavigationHeader(title: "") {
            if !model.isOneToOne {
                Button {
                    model.onEditTap()
                } label: {
                    AnytypeText(Loc.edit, style: .bodyRegular)
                        .foregroundStyle(Color.Text.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .glassEffectInteractiveIOS26(in: Capsule())
            }
        }
    }

    private var spaceDetails: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                spaceIconView
                HStack(spacing: 4) {
                    Menu {
                        spaceNameMenuItems
                    } label: {
                        AnytypeText(model.spaceName.isNotEmpty ? model.spaceName : Loc.untitled, style: .heading)
                    }
                    if model.isOneToOne, model.hasMembership {
                        Image(asset: .X18.membershipBadge)
                            .frame(width: 20, height: 20)
                    }
                }
                if model.isOneToOne {
                    if model.anytypeName.isNotEmpty {
                        Spacer.fixedHeight(4)
                        AnytypeText(model.anytypeName, style: .caption1Regular)
                            .foregroundStyle(Color.Text.transparentSecondary)
                    }
                } else {
                    Spacer.fixedHeight(4)
                    AnytypeText(Loc.membersPlural(model.participantsCount), style: .caption1Regular).foregroundStyle(Color.Text.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var spaceIconView: some View {
        let iconContent = VStack(spacing: 0) {
            Spacer.fixedHeight(8)
            IconView(icon: model.spaceIcon).frame(width: 112, height: 112)
            Spacer.fixedHeight(16)
        }

        if !model.isOneToOne {
            Button {
                model.onChangeIconTap()
            } label: {
                iconContent
            }
        } else {
            iconContent
        }
    }

    private var spaceNameMenuItems: some View {
        VStack {
            Button {
                model.onCopyTitleTap()
            } label: {
                Text(Loc.copy)
                Spacer()
                Image(systemName: "document.on.document")
            }
            if !model.isOneToOne {
                Button {
                    model.onEditTap()
                } label: {
                    Text(Loc.edit)
                    Spacer()
                    Image(systemName: "pencil")
                }
            }
        }
    }

    private var sharing: some View {
        Group {
        if model.inviteLink.isNotNil {
            Spacer.fixedHeight(24)

            GlassEffectContainerIOS26(spacing: 24) {
                HStack(spacing: 24) {
                    Button {
                        model.onShareTap()
                    } label: {
                        inviteLinkActionView(asset: .X32.shareLink, title: Loc.SpaceShare.Share.link)
                    }

                    Button {
                        model.onCopyLinkTap()
                    } label: {
                        inviteLinkActionView(asset: .X32.copyLink, title: Loc.copyLink)
                    }

                    Button {
                        model.onQRCodeTap()
                    } label: {
                        inviteLinkActionView(asset: .X32.qrCode, title: Loc.qrCode)
                    }
                }
            }

            Spacer.fixedHeight(16)
        }
        }.animation(.default, value: model.inviteLink)
    }

    private func inviteLinkActionView(asset: ImageAsset, title: String) -> some View {
        VStack(spacing: 0) {
            Image(asset: asset)
                .foregroundStyle(Color.Text.primary)
                .frame(width: 24, height: 24)
                .frame(width: 64, height: 64)
                .glassEffectInteractiveIOS26(in: Circle())

            Spacer.fixedHeight(6)

            AnytypeText(title, style: .caption2Regular)
                .foregroundStyle(Color.Text.primary)
        }
    }

    @ViewBuilder
    private var collaboration: some View {
        switch model.shareSection {
        case .personal:
            EmptyView()
        case let .private(state):
            privateSpaceSetting(state: state)
        case .owner:
            collaborationSection(memberDecoration: ownerButtonDecoration())
        case .editor:
            collaborationSection(memberDecoration: .chevron)
        case .viewer:
            collaborationSection()
        }
    }

    private func collaborationSection(memberDecoration: RoundedButtonDecoration? = nil) -> some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.collaboration)
            SettingsSection {
                if !model.isOneToOne {
                    RoundedButton(
                        Loc.members,
                        icon: .X24.member,
                        decoration: memberDecoration
                    ) { model.onMembersTap() }
                    .settingsRow(showDivider: true, leadingPadding: 48)
                }
                RoundedButton(
                    Loc.notifications,
                    icon: pushNotificationsSettingIcon(),
                    decoration: .caption(pushNotificationsSettingCaption())
                ) { model.onNotificationsTap() }
                .settingsRow(showDivider: model.uxTypeSettingsData != nil, leadingPadding: 48)
                if let data = model.uxTypeSettingsData {
                    RoundedButton(
                        Loc.channelType,
                        icon: data.icon,
                        decoration: .caption(data.typaName)
                    ) { model.onUxTypeTap() }
                    .settingsRow(showDivider: false, leadingPadding: 48)
                }
            }
        }
    }

    private func privateSpaceSetting(state: PrivateSpaceSettingsShareSection) -> some View {
        Group {
            switch state {
            case .unshareable:
                EmptyView()
            case .shareable, .reachedSharesLimit:
                if !model.isOneToOne {
                    SectionHeaderView(title: Loc.collaboration)
                    SettingsSection {
                        RoundedButton(
                            Loc.members,
                            icon: .X24.member,
                            decoration: .chevron
                        ) { model.onMembersTap() }
                        .settingsRow(showDivider: false, leadingPadding: 48)
                    }
                }
            }
        }
    }

    private func ownerButtonDecoration() -> RoundedButtonDecoration {
        if !model.canAddWriters {
            return .alert
        } else if model.joiningCount > 0 {
            return .badge(model.joiningCount)
        } else {
            return .chevron
        }
    }

    @ViewBuilder
    private var contentModel: some View {
        SectionHeaderView(title: Loc.contentModel)
        SettingsSection {
            RoundedButton(
                Loc.objectTypes,
                icon: .X24.objectType,
                decoration: .chevron
            ) { model.onObjectTypesTap() }
            .settingsRow(showDivider: true, leadingPadding: 48)
            RoundedButton(
                Loc.properties,
                icon: .X24.properties,
                decoration: .chevron
            ) { model.onPropertiesTap() }
            .settingsRow(showDivider: false, leadingPadding: 48)
        }
    }

    @ViewBuilder
    private var preferences: some View {
        SectionHeaderView(title: Loc.preferences)
        SettingsSection {
            if FeatureFlags.homePage {
                RoundedButton(
                    Loc.SpaceSettings.HomePage.title,
                    decoration: model.homePageState.buttonDecoration
                ) { model.onHomePageTap() }
                .settingsRow(showDivider: true)
            }
            RoundedButton(
                Loc.defaultObjectType,
                decoration: .init(objectType: model.defaultObjectType)
            ) { model.onDefaultObjectTypeTap() }
            .settingsRow(showDivider: true)
            RoundedButton(
                Loc.wallpaper,
                decoration: .chevron
            ) { model.onWallpaperTap() }
            .settingsRow(showDivider: false)
        }
    }

    @ViewBuilder
    private var dataManagement: some View {
        SectionHeaderView(title: Loc.Settings.dataManagement)
        if model.allowRemoteStorage {
            Button {
                model.onStorageTap()
            } label: {
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Image(asset: .X24.storage)
                            .renderingMode(.template)
                            .foregroundStyle(Color.Text.primary)
                            .frame(width: 20, height: 20)
                        Spacer.fixedWidth(12)
                        AnytypeText(Loc.SpaceSettings.remoteStorage, style: .bodySemibold)
                        Spacer()
                        IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 16)

                    RemoteStorageSegment(model: model.storageInfo, showLegend: false).padding(.horizontal, 16)
                    Spacer.fixedHeight(16)
                }
                .background(Color.Background.primary)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            Spacer.fixedHeight(8)
        }

        SettingsSection {
            RoundedButton(
                Loc.bin,
                icon: .X24.bin,
                decoration: .chevron
            ) { model.onBinTap() }
            .settingsRow(showDivider: false, leadingPadding: 48)
        }
    }

    @ViewBuilder
    private var misc: some View {
        SectionHeaderView(title: Loc.misc)

        SettingsSection {
            RoundedButton(
                Loc.SpaceSettings.info
            ) { model.onInfoTap() }
            .settingsRow(showDivider: model.allowDelete || model.allowLeave)

            if model.allowDelete {
                RoundedButton(
                    Loc.SpaceSettings.deleteButton,
                    textColor: .Pure.red
                ) { model.onDeleteTap() }
                .settingsRow(showDivider: model.allowLeave)
            }
            if model.allowLeave {
                RoundedButton(
                    Loc.SpaceSettings.leaveButton,
                    textColor: .Pure.red
                ) { model.onLeaveTap() }
                .settingsRow(showDivider: false)
            }
        }
    }

    private func pushNotificationsSettingIcon() -> ImageAsset {
        guard let status = model.pushNotificationsSettingsStatus, status.isAuthorized else {
            return .X24.muted
        }
        return model.pushNotificationsSettingsMode.isEnabled ? .X24.unmuted : .X24.muted
    }

    private func pushNotificationsSettingCaption() -> String {
        guard let status = model.pushNotificationsSettingsStatus, status.isAuthorized else {
            return SpacePushNotificationsMode.nothing.titleShort
        }
        return model.pushNotificationsSettingsMode.titleShort
    }
}

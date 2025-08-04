import Foundation
import SwiftUI
import AnytypeCore
import Services

struct SpaceSettingsView: View {
    
    @StateObject private var model: SpaceSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(workspaceInfo: AccountInfo, output: (any SpaceSettingsModuleOutput)?) {
        _model = StateObject(wrappedValue: SpaceSettingsViewModel(workspaceInfo: workspaceInfo, output: output))
    }
    
    var body: some View {
        content
            .homeBottomPanelHidden(true)
            .onAppear {
                model.onAppear()
            }
            .task {
                await model.startSubscriptions()
            }
            .onChange(of: model.dismiss) { _ in
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
                QrCodeView(title: Loc.SpaceShare.Qr.title, data: $0.absoluteString, analyticsType: .inviteSpace)
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
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
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
        }
    }
    
    private var header: some View {
        PageNavigationHeader(title: "") {
            Button {
                model.onEditTap()
            } label: {
                AnytypeText(Loc.edit, style: .bodyRegular).foregroundColor(.Control.secondary)
            }
        }
    }
    
    private var spaceDetails: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Button {
                    model.onChangeIconTap()
                } label: {
                    VStack(spacing: 0) {
                        Spacer.fixedHeight(8)
                        IconView(icon: model.spaceIcon).frame(width: 112, height: 112)
                        Spacer.fixedHeight(16)
                    }
                }
                AnytypeText(model.spaceName.isNotEmpty ? model.spaceName : Loc.untitled, style: .heading)
                Spacer.fixedHeight(4)
                AnytypeText(Loc.membersPlural(model.participantsCount), style: .caption1Regular).foregroundColor(.Text.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var sharing: some View {
        if model.inviteLink.isNotNil {
            Spacer.fixedHeight(24)
            
            HStack(spacing: 24) {
                Button {
                    model.onInviteTap()
                } label: {
                    inviteLinkActionView(asset: .X32.linkTo, title: Loc.SpaceShare.Share.link)
                }
                
                Button {
                    model.onCopyLinkTap()
                } label: {
                    inviteLinkActionView(asset: .X32.copy, title: Loc.copyLink)
                }
                
                Button {
                    model.onQRCodeTap()
                } label: {
                    inviteLinkActionView(asset: .X32.qrCode, title: Loc.qrCode)
                }
            }
            
            Spacer.fixedHeight(16)
        }
    }
    
    private func inviteLinkActionView(asset: ImageAsset, title: String) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Image(asset: asset)
                    .foregroundStyle(Color.Text.primary)
                    .frame(width: 24, height: 24)
            }
            .padding(20)
            .background(Color.Shape.transperentSecondary)
            .cornerRadius(10)
            
            Spacer.fixedHeight(6)
            
            AnytypeText(title, style: .caption2Regular)
                .foregroundColor(.Text.primary)
        }
    }
    
    @ViewBuilder
    private var collaboration: some View {
        switch model.shareSection {
        case .personal:
            EmptyView()
        case let .private(state):
            privateSpaceSetting(state: state)
        case .ownerOrEditor(let joiningCount):
            collaborationSection(memberDecoration: joiningCount > 0 ? .caption("\(joiningCount)") : .chervon)
        case .viewer:
            collaborationSection()
        }
    }
    
    private func collaborationSection(memberDecoration: RoundedButtonDecoration? = nil) -> some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.collaboration)
            RoundedButton(Loc.members, icon: .X24.member, decoration: memberDecoration) { model.onShareTap() }
            if FeatureFlags.muteSpacePossibility {
                Spacer.fixedHeight(8)
                RoundedButton(
                    Loc.notifications,
                    icon: pushNotificationsSettingIcon(),
                    decoration: .caption(pushNotificationsSettingCaption())) {
                        model.onNotificationsTap()
                    }
            }
        }
    }
    
    func privateSpaceSetting(state: PrivateSpaceSettingsShareSection) -> some View {
        Group {
            switch state {
            case .unshareable:
                EmptyView()
            case .shareable:
                SectionHeaderView(title: Loc.collaboration)
                RoundedButton(Loc.share, icon: .X24.member, decoration: .chervon) { model.onShareTap() }
            case .reachedSharesLimit(let limit):
                SectionHeaderView(title: Loc.collaboration)
                VStack(alignment: .leading, spacing: 0) {
                    RoundedButton(Loc.share, icon: .X24.member, decoration: .chervon) { }
                        .disabled(true)
                    AnytypeText(Loc.Membership.Upgrade.spacesLimit(limit), style: .caption1Regular)
                        .foregroundColor(.Text.primary)
                    Spacer.fixedHeight(10)
                    StandardButton("\(MembershipConstants.membershipSymbol.rawValue) \(Loc.Membership.Upgrade.moreSpaces)", style: .upgradeBadge) {
                        model.onMembershipUpgradeTap()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentModel: some View {
        SectionHeaderView(title: Loc.contentModel)
        RoundedButton(Loc.objectTypes, icon: .X24.objectType, decoration: .chervon) { model.onObjectTypesTap() }
        Spacer.fixedHeight(8)
        RoundedButton(Loc.properties, icon: .X24.properties, decoration: .chervon) { model.onPropertiesTap() }
    }
    
    @ViewBuilder
    private var preferences: some View {
        SectionHeaderView(title: Loc.preferences)
        RoundedButton(
            Loc.defaultObjectType,
            decoration: .init(objectType: model.defaultObjectType)
        ) { model.onDefaultObjectTypeTap() }
        Spacer.fixedHeight(8)
        RoundedButton(Loc.wallpaper, decoration: .chervon) { model.onWallpaperTap() }
        if let isCreateTypeWidget = model.isCreateTypeWidget {
            Spacer.fixedHeight(8)
            RoundedButtonView(Loc.Settings.autoCreateTypeWidgets, decoration: .toggle(isOn: isCreateTypeWidget, onToggle: { isOn in
                UISelectionFeedbackGenerator().selectionChanged()
                model.toggleCreateTypeWidgetState(isOn: isOn)
            }))
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
                            .frame(width: 24, height: 24)
                        Spacer.fixedWidth(8)
                        AnytypeText(Loc.SpaceSettings.remoteStorage, style: .previewTitle1Regular)
                        Spacer()
                        Image(asset: .RightAttribute.disclosure)
                    }
                    .padding(20)
                    
                    RemoteStorageSegment(model: model.storageInfo, showLegend: false).padding(.horizontal, 16)
                    Spacer.fixedHeight(16)
                }
                .border(12, color: .Shape.primary, lineWidth: 0.5)
            }
            
            Spacer.fixedHeight(6)
        }
        
        RoundedButton(Loc.bin, icon: .X24.bin, decoration: .chervon) {
            model.onBinTap()
        }
    }
    
    @ViewBuilder
    private var misc: some View {
        SectionHeaderView(title: Loc.misc)
        
        RoundedButton(Loc.SpaceSettings.info) {
            model.onInfoTap()
        }
        
        Spacer.fixedHeight(8)
        
        if model.allowDelete {
            RoundedButton(Loc.SpaceSettings.deleteButton, textColor: .Pure.red) {
                model.onDeleteTap()
            }
        }
        if model.allowLeave {
            RoundedButton(Loc.SpaceSettings.leaveButton, textColor: .Pure.red) {
                model.onLeaveTap()
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
            return SpaceNotificationsSettingsMode.disabled.titleShort
        }
        return model.pushNotificationsSettingsMode.titleShort
    }
}


import Foundation
import SwiftUI
import AnytypeCore
import Services

struct NewSpaceSettingsView: View {
    
    @StateObject private var model: NewSpaceSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(workspaceInfo: AccountInfo, output: (any NewSpaceSettingsModuleOutput)?) {
        _model = StateObject(wrappedValue: NewSpaceSettingsViewModel(workspaceInfo: workspaceInfo, output: output))
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
        
            .anytypeShareView(item: $model.shareInviteLink)
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
        PageNavigationHeader(title: "")
    }
    
    private var spaceDetails: some View {
        VStack(spacing: 0) {
            Button {
                model.onChangeIconTap()
            } label: {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(8)
                    IconView(icon: model.spaceIcon).frame(width: 112, height: 112)
                    Spacer.fixedHeight(8)
                    AnytypeText(Loc.Settings.editPicture, style: .caption1Medium).foregroundColor(.Text.secondary)
                }
            }
            
            Spacer.fixedHeight(24)
            
            Button {
                model.onTitleTap()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        AnytypeText(Loc.name, style: .uxCalloutRegular).foregroundColor(.Text.secondary)
                        AnytypeText(model.spaceName.isNotEmpty ? model.spaceName : Loc.untitled, style: .bodySemibold)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .border(12, color: .Shape.primary, lineWidth: 0.5)
            }
            
            Spacer.fixedHeight(12)
            
            Button {
                model.onDescriptionTap()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        AnytypeText(Loc.description, style: .uxCalloutRegular).foregroundColor(.Text.secondary)
                        AnytypeText(model.spaceDescription.isNotEmpty ? model.spaceDescription : Loc.empty, style: .bodyRegular)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .border(12, color: .Shape.primary, lineWidth: 0.5)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var sharing: some View {
        if model.shareSection.isSharingAvailable {
            Spacer.fixedHeight(8)
            
            HStack(spacing: 8) {
                Button {
                    model.onInviteTap()
                } label: {
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Image(asset: .X32.Island.addMember)
                                .foregroundStyle(Color.Text.primary)
                                .frame(width: 32, height: 32)
                            AnytypeText(Loc.invite, style: .caption1Regular)
                        }
                        .padding(.vertical, 14)
                        Spacer()
                    }
                    .border(12, color: .Shape.primary, lineWidth: 0.5)
                }
                
                Button {
                    model.onQRCodeTap()
                } label: {
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Image(asset: .X32.qrCode)
                                .foregroundStyle(Color.Text.primary)
                                .frame(width: 32, height: 32)
                            AnytypeText(Loc.qrCode, style: .caption1Regular)
                        }
                        .padding(.vertical, 14)
                        Spacer()
                    }
                    .border(12, color: .Shape.primary, lineWidth: 0.5)
                }
            }
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
            SectionHeaderView(title: Loc.collaboration)
            RoundedButton(Loc.members, icon: .X24.member, decoration: joiningCount > 0 ? .badge(joiningCount) : .chervon) { model.onShareTap() }
        case .viewer:
            SectionHeaderView(title: Loc.collaboration)
            RoundedButton(Loc.members, icon: .X24.member) { model.onShareTap() }
        }
        
        if let isChatOn = model.isChatOn {
            Spacer.fixedHeight(8)
            RoundedButtonView(Loc.chat, decoration: .toggle(isOn: isChatOn, onToggle: { isOn in
                UISelectionFeedbackGenerator().selectionChanged()
                model.toggleChatState(isOn: isOn)
            }))
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
    }
    
    @ViewBuilder
    private var dataManagement: some View {
        if model.allowRemoteStorage {
            SectionHeaderView(title: Loc.Settings.dataManagement)
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
                        IconView(asset: .X24.Arrow.right).frame(width: 24, height: 24)
                    }
                    .padding(20)
                    
                    RemoteStorageSegment(model: model.storageInfo, showLegend: false).padding(.horizontal, 16)
                    Spacer.fixedHeight(16)
                }
                .border(12, color: .Shape.primary, lineWidth: 0.5)
            }
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
            RoundedButton(Loc.SpaceSettings.deleteButton, textColor: .Dark.red) {
                model.onDeleteTap()
            }
        }
        if model.allowLeave {
            RoundedButton(Loc.SpaceSettings.leaveButton, textColor: .Dark.red) {
                model.onLeaveTap()
            }
        }
    }
}


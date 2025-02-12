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
            .snackbar(toastBarData: $model.snackBarData)
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
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    spaceDetailsButton
                    sharing
                    collaboration
                    preferences
                    dataManagement
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var header: some View {
        PageNavigationHeader(title: "", rightView: {
            Menu {
                Button(Loc.SpaceSettings.info) {
                    model.onInfoTap()
                }
                
                if model.allowDelete {
                    Button(Loc.SpaceSettings.deleteButton, role: .destructive) {
                        model.onDeleteTap()
                    }
                }
                if model.allowLeave {
                    Button(Loc.SpaceSettings.leaveButton, role: .destructive) {
                        model.onLeaveTap()
                    }
                }
            } label: {
                IconView(asset: .X24.more)
                    .foregroundStyle(Color.Control.active)
                    .frame(width: 24, height: 24)
                    .padding()
            }
        })
    }
    
    private var spaceDetailsButton: some View {
        Button {
            model.onSpaceDetailsTap()
        } label: {
            HStack(spacing: 0) {
                if let icon = model.spaceIcon {
                    IconView(icon: icon)
                        .frame(width: 56, height: 56)
                }
                
                Spacer.fixedWidth(12)
                
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(model.spaceDisplayName, style: .bodySemibold)
                    Spacer.fixedHeight(2)
                    AnytypeText(model.spaceDisplayDescription, style: .uxTitle2Regular)
                        .foregroundColor(.Text.secondary)
                }
                
                Spacer.fixedWidth(12)
                
                Spacer()
                
                if model.allowEditSpace {
                    IconView(asset: .X24.Arrow.right)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .border(16, color: .Shape.primary, lineWidth: 0.5)
        }
        .disabled(!model.allowEditSpace)
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
        case .owner(let joiningCount):
            SectionHeaderView(title: Loc.collaboration)
            RoundedButton(text: Loc.members, icon: .X24.member, decoration: joiningCount > 0 ? .badge(joiningCount) : nil) { model.onShareTap() }
        case .member:
            SectionHeaderView(title: Loc.collaboration)
            RoundedButton(text: Loc.members, icon: .X24.member) { model.onMembersTap() }
        }
    }
    
    func privateSpaceSetting(state: PrivateSpaceSettingsShareSection) -> some View {
        Group {
            switch state {
            case .unshareable:
                EmptyView()
            case .shareable:
                SectionHeaderView(title: Loc.collaboration)
                RoundedButton(text: Loc.share, icon: .X24.member) { model.onShareTap() }
            case .reachedSharesLimit(let limit):
                SectionHeaderView(title: Loc.collaboration)
                VStack(alignment: .leading, spacing: 0) {
                    RoundedButton(text: Loc.share, icon: .X24.member) { }
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
    private var preferences: some View {
        SectionHeaderView(title: Loc.preferences)
        RoundedButton(
            text: Loc.defaultObjectType,
            decoration: .init(objectType: model.defaultObjectType)
        ) { model.onDefaultObjectTypeTap() }
        Spacer.fixedHeight(8)
        RoundedButton(text: Loc.wallpaper) { model.onWallpaperTap() }
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
}


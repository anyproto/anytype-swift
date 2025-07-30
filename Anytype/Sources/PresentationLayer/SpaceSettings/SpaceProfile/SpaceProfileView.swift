import SwiftUI
import Services


struct SpaceProfileView: View {
    @StateObject private var model: SpaceProfileViewModel
    
    init(info: AccountInfo) {
        _model = StateObject(wrappedValue: SpaceProfileViewModel(info: info))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }

            .sheet(item: $model.shareInviteLink) { link in
                ActivityView(activityItems: [link])
            }
            .anytypeSheet(isPresented: $model.showSpaceDeleteAlert) {
                SpaceDeleteAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showSpaceLeaveAlert) {
                SpaceLeaveAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showInfoView) {
                SpaceSettingsInfoView(info: model.settingsInfo)
            }
            .anytypeSheet(item: $model.qrInviteLink) {
                QrCodeView(title: Loc.SpaceShare.Qr.title, data: $0.absoluteString, analyticsType: .inviteSpace)
            }
            .snackbar(toastBarData: $model.snackBarData)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            header
            IconView(icon: model.spaceIcon).frame(width: 112, height: 112)
            Spacer.fixedHeight(17)
            AnytypeText(model.spaceName, style: .heading)
            Spacer.fixedHeight(7)
            if model.spaceDescription.isNotEmpty {
                AnytypeText(model.spaceDescription, style: .uxCalloutRegular)
                Spacer.fixedHeight(12)
            }
            sharing
            Spacer.fixedHeight(24)
        }
        .background(Color.Background.secondary)
    }
    
    private var header: some View {
        HStack {
            Spacer()
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
                IconView(asset: .X32.more)
            }
            
            Spacer.fixedWidth(12)
        }.frame(height: 48)
    }
    
    @ViewBuilder
    private var sharing: some View {
        if model.inviteLink.isNotNil {
            Spacer.fixedHeight(8)
            
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
            }.padding(.horizontal, 16)
            
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
}


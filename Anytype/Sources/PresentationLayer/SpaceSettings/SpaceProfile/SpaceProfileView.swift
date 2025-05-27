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
            }.padding(.horizontal, 16)
        }
    }
}


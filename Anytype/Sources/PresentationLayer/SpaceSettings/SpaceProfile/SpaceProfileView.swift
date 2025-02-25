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
            .anytypeSheet(isPresented: $model.showSpaceDeleteAlert) {
                SpaceDeleteAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showSpaceLeaveAlert) {
                SpaceLeaveAlert(spaceId: model.workspaceInfo.accountSpaceId)
            }
            .anytypeSheet(isPresented: $model.showInfoView) {
                SpaceSettingsInfoView(info: model.settingsInfo)
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
            RoundedRectangle(cornerRadius: 12).frame(height: 78).foregroundStyle(Color.System.amber50).overlay(alignment: .center) {
                AnytypeText("Share buttons here", style: .bodySemibold)
            }.padding()
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
}


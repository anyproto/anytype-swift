import Foundation
import SwiftUI

struct NewInviteLinkView: View {
    
    @StateObject private var model: NewInviteLinkViewModel
    
    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self._model = StateObject(wrappedValue: NewInviteLinkViewModel(data: data, output: output))
    }
    
    var body: some View {
        Group {
            if model.showInitialLoading {
                loadingView
            } else if model.shareLink.isNotNil {
                linkContent
            } else {
                linkStateButton
            }
        }
        .transition(.opacity)
        .background(Color.Background.primary)
        .animation(.default, value: model.shareLink)
        .animation(.default, value: model.inviteType)
        .task {
            await model.onAppear()
        }
        .anytypeSheet(item: $model.invitePickerItem) {
            InviteTypePicker(currentType: $0) { type in
                model.onInviteLinkTypeSelected(type)
            }
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
    
    private var loadingView: some View {
        VStack {
            CircleLoadingView()
                .frame(width: 32, height: 32)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
    }
    
    private var linkContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            linkStateButton
            linkView
            Spacer.fixedHeight(8)
            StandardButton(Loc.copyLink, style: .primaryLarge) {
                model.onCopyLink()
            }
        }
    }
    
    private var linkStateButton: some View {
        Button {
            model.onLinkTypeTap()
        } label: {
            HStack {
                InviteStateView(richInviteType: model.inviteType)
                Spacer()
                if model.isLoading {
                    CircleLoadingView()
                        .frame(width: 24, height: 24)
                } else {
                    Image(asset: .RightAttribute.disclosure)
                }
            }
        }.disabled(model.isLoading)
    }
    
    private var linkView: some View {
        HStack {
            Button {
                model.onCopyLink()
            } label: {
                AnytypeText(model.shareLink?.absoluteString ?? "", style: .uxCalloutRegular)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
            }
            Menu {
                Button() {
                    model.onCopyInviteLink()
                } label: {
                    Text(Loc.SpaceShare.CopyInviteLink.title)
                    Spacer()
                    Image(systemName: "link")
                }
                Button() {
                    model.onShareInvite()
                } label: {
                    Text(Loc.SpaceShare.Share.link)
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                }
                Button() {
                    model.onShowQrCode()
                } label: {
                    Text(Loc.SpaceShare.Qr.button)
                    Spacer()
                    Image(systemName: "qrcode")
                }
            } label: {
                IconView(icon: .asset(.X24.more))
                    .frame(width: 24, height: 24)
            }
            .menuOrder(.fixed)
        }
        .padding(.horizontal, 12)
        .background(Color.Shape.transperentTertiary)
        .cornerRadius(10, style: .circular)
    }
}

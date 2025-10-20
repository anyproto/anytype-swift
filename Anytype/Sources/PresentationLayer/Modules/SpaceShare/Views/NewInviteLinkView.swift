import Foundation
import SwiftUI

struct NewInviteLinkView: View {

    @StateObject private var model: NewInviteLinkViewModel
    @Binding private var notifyUpdateLinkView: UUID
    let canChangeInvite: Bool
    let hasReachedSharedSpacesLimit: Bool

    init(data: SpaceShareData, notifyUpdateLinkView: Binding<UUID>, canChangeInvite: Bool, hasReachedSharedSpacesLimit: Bool, output: (any NewInviteLinkModuleOutput)?) {
        self.canChangeInvite = canChangeInvite
        self.hasReachedSharedSpacesLimit = hasReachedSharedSpacesLimit
        self._notifyUpdateLinkView = notifyUpdateLinkView
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
                    .opacity(hasReachedSharedSpacesLimit ? 0.5 : 1)
                    .disabled(hasReachedSharedSpacesLimit)
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
        .anytypeSheet(item: $model.inviteChangeConfirmation) { invite in
            SpaceInviteChangeAlert {
                model.onInviteChangeConfirmed(invite)
            }
        }
        .onChange(of: notifyUpdateLinkView) {
            model.updateLink()
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
                model.onCopyLink(route: .button)
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
                } else if canChangeInvite {
                    Image(asset: .RightAttribute.disclosure)
                }
            }
        }.disabled(model.isLoading || !canChangeInvite)
    }
    
    private var linkView: some View {
        HStack {
            Button {
                model.onCopyLink(route: .menu)
            } label: {
                AnytypeText(model.shareLink?.absoluteString ?? "", style: .uxCalloutRegular)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
            }
            Menu {
                Button() {
                    model.onCopyLink(route: .menu)
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

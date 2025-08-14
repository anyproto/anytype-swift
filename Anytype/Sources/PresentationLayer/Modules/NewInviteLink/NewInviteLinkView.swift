import Foundation
import SwiftUI

struct NewInviteLinkView: View {
    
    @StateObject private var model: NewInviteLinkViewModel
    
    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self._model = StateObject(wrappedValue: NewInviteLinkViewModel(data: data, output: output))
    }
    
    var body: some View {
        Group {
            if model.firstOpen {
                loadingView
            } else if model.shareLink.isNotNil {
                linkContent
            } else {
                emptyLinkContent
            }
        }
        .padding(20)
        .background(Color.Background.secondary)
        .cornerRadius(16, style: .continuous)
        .shadow(radius: 16)
        .task {
            await model.startSubscription()
        }
        .anytypeSheet(item: $model.deleteLinkSpaceId) {
            DeleteSharingLinkAlert(spaceId: $0.value) {
                model.onDeleteLinkCompleted()
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
            HStack {
                AnytypeText(Loc.SpaceShare.Invite.title, style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
                Spacer()
                Menu {
                    if model.canCopyInviteLink {
                        Button() {
                            model.onCopyInviteLink()
                        } label: {
                            Text(Loc.SpaceShare.CopyInviteLink.title)
                        }
                    }
                    Button(role: .destructive) {
                        model.onDeleteSharingLink()
                    } label: {
                        Text(Loc.SpaceShare.DeleteSharingLink.title)
                    }
                    .disabled(!model.canDeleteLink)
                } label: {
                    IconView(icon: .asset(.X24.more))
                        .frame(width: 24, height: 24)
                }
                .menuOrder(.fixed)
            }
            Spacer.fixedHeight(4)
            Button {
                model.onCopyLink()
            } label: {
                AnytypeText(model.shareLink?.absoluteString ?? "", style: .uxCalloutRegular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                    .frame(height: 48)
                    .newDivider()
            }
            Spacer.fixedHeight(10)
            AnytypeText(model.description, style: .relation3Regular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(20)
            StandardButton(model.isStream ? Loc.SpaceShare.Share.link : Loc.SpaceShare.Invite.share, style: .primaryLarge) {
                model.onShareInvite()
            }
            Spacer.fixedHeight(10)
            StandardButton(Loc.SpaceShare.Qr.button, style: .secondaryLarge) {
                model.onShowQrCode()
            }
        }
    }
    
    private var emptyLinkContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(Loc.SpaceShare.Invite.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.SpaceShare.Invite.empty, style: .calloutRegular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(12)
            AsyncStandardButton(Loc.SpaceShare.Invite.generate, style: .primaryLarge) {
                try await model.onGenerateInvite()
            }
        }
    }
}
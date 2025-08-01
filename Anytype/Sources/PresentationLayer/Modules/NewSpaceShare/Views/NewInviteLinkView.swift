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
                InviteStateView(invite: model.invite)
            }
        }
        .background(Color.Background.primary)
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
            InviteStateView(invite: model.invite)
            linkView
            Spacer.fixedHeight(8)
            StandardButton(Loc.copyLink, style: .primaryLarge) {
                model.onCopyLink()
            }
        }
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
        .padding(.horizontal, 12)
        .background(Color.Shape.transperentTertiary)
        .cornerRadius(10, style: .circular)
    }
}

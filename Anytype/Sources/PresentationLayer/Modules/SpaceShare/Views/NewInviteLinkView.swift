import Foundation
import SwiftUI

struct NewInviteLinkView: View {

    @Bindable var model: NewInviteLinkViewModel
    let canChangeInvite: Bool
    let hasReachedSharedSpacesLimit: Bool

    init(model: NewInviteLinkViewModel, canChangeInvite: Bool, hasReachedSharedSpacesLimit: Bool) {
        self.model = model
        self.canChangeInvite = canChangeInvite
        self.hasReachedSharedSpacesLimit = hasReachedSharedSpacesLimit
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
                    .disabled(model.isLoading || !canChangeInvite || hasReachedSharedSpacesLimit)
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
            StandardButton(Loc.copyLink, style: .primaryMedium) {
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
        Button {
            model.onCopyLink(route: .menu)
        } label: {
            AnytypeText(model.shareLink?.absoluteString ?? "", style: .uxCalloutRegular)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
        .background(Color.Shape.transparentTertiary)
        .cornerRadius(10, style: .circular)
    }
}

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
        content
            .transition(.opacity)
            .background(Color.Background.primary)
            .animation(.default, value: model.shareLink)
            .animation(.default, value: model.inviteType)
            .task {
                await model.onAppear()
            }
            .anytypeSheet(item: $model.invitePickerItem) {
                InviteTypePicker(currentType: $0, disabledTypes: model.disabledPickerTypes) { type in
                    model.onInviteLinkTypeSelected(type)
                }
            }
            .anytypeSheet(item: $model.inviteChangeConfirmation) { invite in
                SpaceInviteChangeAlert {
                    model.onInviteChangeConfirmed(invite)
                }
            }
            .anytypeSheet(isPresented: $model.showShareConfirmation) {
                ShareInviteWithSpaceAlert {
                    model.onShareConfirmed()
                }
            }
            .anytypeSheet(isPresented: $model.showResetConfirmation) {
                ResetInviteLinkAlert {
                    model.onResetConfirmed()
                }
            }
            .snackbar(toastBarData: $model.toastBarData)
    }

    @ViewBuilder
    private var content: some View {
        if model.showInitialLoading {
            loadingView
        } else if model.inviteHeldByOwner {
            heldByOwnerView
        } else if model.shareLink.isNotNil {
            linkContent
        } else {
            linkStateButton
                .opacity(hasReachedSharedSpacesLimit ? 0.5 : 1)
                .disabled(model.isLoading || !canChangeInvite || hasReachedSharedSpacesLimit)
        }
    }

    private var loadingView: some View {
        VStack {
            CircleLoadingView()
                .frame(width: 32, height: 32)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
    }

    private var heldByOwnerView: some View {
        AnytypeText(Loc.Space.Invite.HeldByOwner.message, style: .uxCalloutRegular)
            .foregroundStyle(Color.Text.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 20)
    }

    private var linkContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            linkStateButton
            linkView
            Spacer.fixedHeight(8)
            StandardButton(Loc.copyLink, style: .primaryMedium) {
                model.onCopyLink(route: .button)
            }
            if canChangeInvite && model.inviteType != nil {
                inviteManagementSection
            }
        }
    }

    private var inviteManagementSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            shareToggleRow
            if let hint = shareToggleHint {
                Spacer.fixedHeight(4)
                caption(hint)
            }
            warningsView
            if model.isSharedWithinSpace {
                Spacer.fixedHeight(16)
                StandardButton(Loc.Space.Invite.Reset.title, style: .warningMedium) {
                    model.onResetLinkTap()
                }
            }
        }
    }

    private var shareToggleRow: some View {
        Toggle(isOn: Binding(
            get: { model.shareToggleState == .onLocked },
            set: { model.onShareToggleChanged($0) }
        )) {
            AnytypeText(Loc.Space.Invite.Share.toggle, style: .uxCalloutRegular)
                .foregroundStyle(Color.Text.primary)
        }
        .toggleStyle(SwitchToggleStyle(tint: .Control.accent50))
        .disabled(model.shareToggleState != .off || model.isLoading)
    }

    private var shareToggleHint: String? {
        switch model.shareToggleState {
        case .off:
            nil
        case .onLocked:
            Loc.Space.Invite.Share.lockedHint
        case .blocked:
            Loc.Space.Invite.Share.disabledReason
        }
    }

    @ViewBuilder
    private var warningsView: some View {
        if model.inviteType == .viewer || model.inviteType == .editor {
            Spacer.fixedHeight(8)
            caption(Loc.Space.Invite.Warning.autoApproval)
        }
        if model.inviteType == .editor {
            Spacer.fixedHeight(4)
            caption(Loc.Space.Invite.Warning.editorUpgrade)
        }
    }

    private func caption(_ text: String) -> some View {
        AnytypeText(text, style: .relation2Regular)
            .foregroundStyle(Color.Text.secondary)
            .fixedSize(horizontal: false, vertical: true)
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
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
        .background(Color.Shape.transparentTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
    }
}

import Foundation
import SwiftUI
import Services

struct WidgetsHeaderView: View {
    @State private var model: WidgetsHeaderViewModel
    let context: WidgetScreenContext

    init(
        spaceId: String,
        context: WidgetScreenContext,
        onSpaceSelected: @escaping () -> Void,
        onMembersSelected: @escaping (String, SettingsSpaceShareRoute) -> Void,
        onQrCodeSelected: @escaping (URL) -> Void
    ) {
        _model = State(initialValue: WidgetsHeaderViewModel(
            spaceId: spaceId,
            onSpaceSelected: onSpaceSelected,
            onMembersSelected: onMembersSelected,
            onQrCodeSelected: onQrCodeSelected
        ))
        self.context = context
    }

    var body: some View {
        NavigationHeader(
            navigationButtonType: context.navigationButtonType,
            isTitleInteractive: false
        ) {
            EmptyView()
        } rightContent: {
            settingsButton
        }
        .task { await model.startSubscriptions() }
    }

    @ViewBuilder
    private var settingsButton: some View {
        if model.canEdit {
            Menu {
                WidgetsHeaderMenuContent(model: $model)
            } label: {
                Image(asset: .X24.more)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
            }
            .glassEffectInteractiveIOS26(in: Circle())
            .snackbar(toastBarData: $model.toastBarData)
        }
    }
}

// MARK: - Menu Content

private struct WidgetsHeaderMenuContent: View {

    @Binding var model: WidgetsHeaderViewModel

    var body: some View {
        channelSettingsButton

        if model.isSharedSpace {
            if !model.isOneToOneSpace {
                membersButton
            }
            notificationsMenu

            if model.hasInviteLink {
                qrCodeButton
                copyInviteLinkButton
            }
        } else if model.isPrivateSpace {
            inviteMembersButton
        }
    }

    // MARK: - Menu Items

    private var channelSettingsButton: some View {
        Button {
            model.onChannelSettingsTap()
        } label: {
            Label(Loc.Chat.channelSettings, systemImage: "gear")
        }
    }

    private var membersButton: some View {
        Button {
            model.onMembersTap()
        } label: {
            Label(Loc.members, systemImage: "person.2.fill")
        }
    }

    private var notificationsMenu: some View {
        NotificationModeMenu(
            currentMode: model.currentNotificationMode,
            onModeChange: { mode in
                await model.onNotificationModeChanged(mode)
            }
        )
    }

    private var inviteMembersButton: some View {
        Button {
            model.onInviteMembersTap()
        } label: {
            Label(Loc.Chat.inviteMembers, systemImage: "person.fill.badge.plus")
        }
    }

    private var qrCodeButton: some View {
        Button {
            model.onShowQrCodeTap()
        } label: {
            Label(Loc.qrCode, systemImage: "qrcode")
        }
    }

    private var copyInviteLinkButton: some View {
        Button {
            model.onCopyInviteLinkTap()
        } label: {
            Label(Loc.copyInviteLink, systemImage: "document.on.document.fill")
        }
    }
}

import SwiftUI

struct SpaceHubToolbar: ToolbarContent {

    let profileIcon: Icon?
    let notificationsNotDetermined: Bool
    let hideCreateButton: Bool
    let quickCaptureEnabled: Bool

    let onTapCreatePersonalChannel: () -> Void
    let onTapCreateGroupChannel: () -> Void
    let onTapJoinViaQrCode: () -> Void
    let onTapSettings: () -> Void
    let onTapQuickCapture: () -> Void

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ios26ToolbarItems
        } else {
            legacyToolbarItems
        }
    }

    @ToolbarContentBuilder
    private var legacyToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                onTapSettings()
            } label: {
                IconView(icon: profileIcon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 28, height: 28)
                    .overlay(alignment: .topTrailing) {
                        if notificationsNotDetermined {
                            attentionDotView
                        }
                    }
                    .padding(.vertical, 8)
            }
        }

        if !hideCreateButton {
            ToolbarItemGroup(placement: .topBarTrailing) {
                SpaceHubNewSpaceButton(
                    onTapPersonal: { onTapCreatePersonalChannel() },
                    onTapGroup: { onTapCreateGroupChannel() },
                    onTapJoinQR: { onTapJoinViaQrCode() }
                )
                if quickCaptureEnabled {
                    quickCaptureButton
                }
            }
        }
    }

    @available(iOS 26.0, *)
    @ToolbarContentBuilder
    private var ios26ToolbarItems: some ToolbarContent {
        if quickCaptureEnabled && !hideCreateButton {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    CreateChannelMenuItems(
                        onTapPersonal: { onTapCreatePersonalChannel() },
                        onTapGroup: { onTapCreateGroupChannel() },
                        onTapJoinQR: { onTapJoinViaQrCode() }
                    )
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.Control.primary)
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onTapSettings()
            } label: {
                IconView(icon: profileIcon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 44, height: 44)
                    .overlay(alignment: .topTrailing) {
                        if notificationsNotDetermined {
                            attentionDotView
                        }
                    }
                    .padding(.vertical, 8)
            }
        }
        .sharedBackgroundVisibility(.hidden)

        if !hideCreateButton {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)

            ToolbarSpacer(placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                if quickCaptureEnabled {
                    quickCaptureButton
                } else {
                    Menu {
                        CreateChannelMenuItems(
                            onTapPersonal: { onTapCreatePersonalChannel() },
                            onTapGroup: { onTapCreateGroupChannel() },
                            onTapJoinQR: { onTapJoinViaQrCode() }
                        )
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.Control.primary)
                    }
                }
            }
        }
    }

    private var quickCaptureButton: some View {
        Button {
            onTapQuickCapture()
        } label: {
            Image(systemName: "square.and.pencil")
                .foregroundStyle(Color.Control.primary)
        }
        .accessibilityLabel("QuickCaptureButton")
    }

    private var attentionDotView: some View {
        SpaceHubAttentionDotView()
            .padding([.top, .trailing], 3)
    }
}

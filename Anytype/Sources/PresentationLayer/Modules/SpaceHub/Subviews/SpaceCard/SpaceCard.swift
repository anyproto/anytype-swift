import SwiftUI
import AnytypeCore
import Services

struct SpaceCard: View {

    let model: SpaceCardModel
    @Binding var draggedSpaceViewId: String?
    let onTap: () -> Void
    let onTapCopy: () -> Void
    let onTapMute: () -> Void
    let onTapNotificationMode: (SpacePushNotificationsMode) -> Void
    let onTapPin: () async throws -> Void
    let onTapUnpin: () async throws -> Void
    let onTapSettings: () -> Void
    let onTapDelete: () -> Void
    let onTapLeave: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            NewSpaceCardLabel(
                model: model,
                draggedSpaceViewId: $draggedSpaceViewId
            )
        }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contextMenu { menuItems.tint(Color.Text.primary) }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        if model.isLoading {
            copyButton
            Divider()
        }
        
        if model.isPinned {
            unpinButton
        } else {
            pinButton
        }

        if model.isShared {
            muteButton
        }

        if !model.isLoading {
            settingsButton
        }

        if model.canBeDeleted {
            Divider()
            deleteButton
        } else if model.canLeave {
            Divider()
            leaveButton
        }
    }
    
    private var copyButton: some View {
        Button {
            onTapCopy()
        } label: {
            Text(Loc.copySpaceInfo)
        }
    }
    
    @ViewBuilder
    private var muteButton: some View {
        if model.supportsMultiChats {
            NotificationModeMenu(
                currentMode: model.currentNotificationMode,
                onModeChange: { onTapNotificationMode($0) }
            )
        } else {
            MuteToggleMenuButton(isMuted: model.isMuted) {
                onTapMute()
            }
        }
    }
    
    private var unpinButton: some View {
        AsyncButton {
            try await onTapUnpin()
        } label: {
            Text(Loc.unpin)
            Spacer()
            Image(systemName: "pin.slash")
        }
    }
    
    private var pinButton: some View {
        AsyncButton {
            try await onTapPin()
        } label: {
            Text(Loc.pin)
            Spacer()
            Image(systemName: "pin")
        }
    }
    
    
    private var settingsButton: some View {
        Button {
            onTapSettings()
        } label: {
            Text(Loc.SpaceSettings.title)
            Spacer()
            Image(systemName: "gearshape")
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            onTapDelete()
        } label: {
            Text(Loc.SpaceSettings.deleteButton)
                .tint(.red)
            Spacer()
            Image(systemName: "trash")
                .tint(.red)
        }
    }

    private var leaveButton: some View {
        Button(role: .destructive) {
            onTapLeave()
        } label: {
            Text(Loc.SpaceSettings.leaveButton)
                .tint(.red)
            Spacer()
            Image(systemName: "trash")
                .tint(.red)
        }
    }
}

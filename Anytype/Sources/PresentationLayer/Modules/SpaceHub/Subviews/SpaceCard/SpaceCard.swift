import SwiftUI
import AnytypeCore

struct SpaceCard: View {

    let model: SpaceCardModel
    @Binding var draggedSpaceViewId: String?
    let onTap: () -> Void
    let onTapCopy: () -> Void
    let onTapMute: () -> Void
    let onTapPin: () async throws -> Void
    let onTapUnpin: () async throws -> Void
    let onTapSettings: () -> Void
    let onTapDelete: () -> Void

    @State private var vaultBackToRootsToggle = FeatureFlags.vaultBackToRoots
    @State private var muteSpacePossibilityToggle = FeatureFlags.muteSpacePossibility
    
    var body: some View {
        Button {
            onTap()
        } label: {
            if !vaultBackToRootsToggle {
                SpaceCardLabel(
                    model: model,
                    draggedSpaceViewId: $draggedSpaceViewId
                )
            } else {
                NewSpaceCardLabel(
                    model: model,
                    draggedSpaceViewId: $draggedSpaceViewId
                )
            }
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
        
        if muteSpacePossibilityToggle, model.isShared {
            muteButton
        }
        
        if model.isLoading {
            deleteButton
        } else {
            settingsButton
        }
    }
    
    private var copyButton: some View {
        Button {
            onTapCopy()
        } label: {
            Text(Loc.copySpaceInfo)
        }
    }
    
    private var muteButton: some View {
        Button {
            onTapMute()
        } label: {
            HStack {
                Text(model.allNotificationsUnmuted ? Loc.mute : Loc.unmute)
                Spacer()
                Image(systemName: model.allNotificationsUnmuted ? "bell.slash" : "bell")
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
}

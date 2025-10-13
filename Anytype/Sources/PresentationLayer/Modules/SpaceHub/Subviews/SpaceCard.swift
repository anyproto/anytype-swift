import SwiftUI
import AnytypeCore

struct SpaceCard: View, @preconcurrency Equatable {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    let onTap: () -> Void
    let onTapCopy: () -> Void
    let onTapMute: () -> Void
    let onTapPin: () async throws -> Void
    let onTapUnpin: () async throws -> Void
    let onTapSettings: () -> Void
    let onTapDelete: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            if !FeatureFlags.vaultBackToRoots {
                SpaceCardLabel(
                    spaceData: spaceData,
                    wallpaper: wallpaper,
                    draggedSpace: $draggedSpace
                )
            } else {
                NewSpaceCardLabel(
                    spaceData: spaceData,
                    wallpaper: wallpaper,
                    draggedSpace: $draggedSpace
                )
            }
        }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contextMenu { menuItems.tint(Color.Text.primary) }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        if spaceData.spaceView.isLoading {
            copyButton
            Divider()
        }
        
        if spaceData.spaceView.isPinned {
            unpinButton
        } else {
            pinButton
        }
        
        if FeatureFlags.muteSpacePossibility, spaceData.spaceView.isShared {
            muteButton
        }
        
        if spaceData.spaceView.isLoading {
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
                Text(spaceData.spaceView.pushNotificationMode.isUnmutedAll ? Loc.mute : Loc.unmute)
                Spacer()
                Image(systemName: spaceData.spaceView.pushNotificationMode.isUnmutedAll ? "bell.slash" : "bell")
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.spaceData == rhs.spaceData
        && lhs.wallpaper == rhs.wallpaper
        && lhs.draggedSpace == rhs.draggedSpace
    }
}

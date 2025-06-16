import SwiftUI
import AnytypeCore

struct SpaceCard: View, @preconcurrency Equatable {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpaper: SpaceWallpaperType
    let draggable: Bool
    let muted: Bool
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    let onTap: () -> Void
    let onTapCopy: () -> Void
    let onTapMute: () -> Void
    let onTapLeave: () -> Void
    let onTapDelete: () async throws -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            SpaceCardLabel(
                spaceData: spaceData,
                wallpaper: wallpaper,
                draggable: draggable,
                muted: muted,
                draggedSpace: $draggedSpace
            )
        }
        .disabled(FeatureFlags.spaceLoadingForScreen ? false : spaceData.spaceView.isLoading)
        .contextMenu { menuItems }
    }
    
    @ViewBuilder
    private var menuItems: some View {
        if spaceData.spaceView.isLoading {
            copyButton
            Divider()
        }
        
        if FeatureFlags.muteSpacePossibility {
            muteButton
            Divider()
        }
        
        if spaceData.space.canLeave {
            leaveButton
        }
        if spaceData.space.canBeDeleted {
            deleteButton
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
                Text(muted ? Loc.unmuteAll : Loc.muteAll)
                Spacer()
                Image(systemName: muted ? "bell" : "bell.slash")
            }
        }
    }
    
    private var leaveButton: some View {
        Button(role: .destructive) {
            onTapLeave()
        } label: {
            Text(Loc.leaveASpace)
        }
    }
    
    private var deleteButton: some View {
        AsyncButton(role: .destructive) {
            try await onTapDelete()
        } label: {
            Text(Loc.delete)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.spaceData == rhs.spaceData
        && lhs.wallpaper == rhs.wallpaper
        && lhs.draggedSpace == rhs.draggedSpace
    }
}

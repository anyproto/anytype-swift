import SwiftUI
import AnytypeCore

struct SpaceCard: View, @preconcurrency Equatable {
    
    let space: ParticipantSpaceViewData
    let wallpeper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewData?
    let onTap: () -> Void
    let onTapCopy: () -> Void
    let onTapPin: () async throws -> Void
    let onTapUnpin: () async throws -> Void
    let onTapLeave: () -> Void
    let onTapDelete: () async throws -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            SpaceCardLabel(
                space: space,
                wallpeper: wallpeper,
                draggedSpace: $draggedSpace
            )
        }
        .disabled(FeatureFlags.spaceLoadingForScreen ? false : space.spaceView.isLoading)
        .contextMenu {
            if !space.spaceView.isLoading {
                menuItems
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var menuItems: some View {
        if space.spaceView.isLoading {
            copyButton
        } else if FeatureFlags.pinnedSpaces {
            if space.spaceView.isPinned {
                unpinButton
            } else {
                pinButton
            }
        }
        
        Divider()
        if space.canLeave {
            leaveButton
        }
        if space.canBeDeleted {
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
    
    private var unpinButton: some View {
        AsyncButton {
            try await onTapUnpin()
        } label: {
            Text(Loc.unpin)
        }
    }
    
    private var pinButton: some View {
        AsyncButton {
            try await onTapPin()
        } label: {
            Text(Loc.pin)
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
        lhs.space == rhs.space
        && lhs.wallpeper == rhs.wallpeper
        && lhs.draggedSpace == rhs.draggedSpace
    }
}

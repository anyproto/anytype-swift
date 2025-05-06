import SwiftUI
import AnytypeCore

struct SpaceCard: View, @preconcurrency Equatable {
    
    let spaceData: ParticipantSpaceViewDataWithPreview
    let wallpeper: SpaceWallpaperType
    @Binding var draggedSpace: ParticipantSpaceViewDataWithPreview?
    let onTap: () -> Void
    let onTapCopy: () -> Void
    let onTapLeave: () -> Void
    let onTapDelete: () async throws -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            SpaceCardLabel(
                spaceData: spaceData,
                wallpeper: wallpeper,
                draggedSpace: $draggedSpace
            )
        }
        .disabled(FeatureFlags.spaceLoadingForScreen ? false : spaceData.spaceView.isLoading)
        .contextMenu {
            if !spaceData.spaceView.isLoading {
                menuItems
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var menuItems: some View {
        if spaceData.spaceView.isLoading {
            copyButton
        }
        
        Divider()
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
        && lhs.wallpeper == rhs.wallpeper
        && lhs.draggedSpace == rhs.draggedSpace
    }
}

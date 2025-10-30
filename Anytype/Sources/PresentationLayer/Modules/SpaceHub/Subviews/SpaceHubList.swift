import SwiftUI
import AnytypeCore

struct SpaceHubList: View {
    
    @Bindable var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewDataWithPreview?
    @State private var draggedInitialIndex: Int?
    @State private var vaultBackToRootsToggle = FeatureFlags.vaultBackToRoots
    
    var body: some View {
        let _ = Self._printChanges()
        return content
    }
    
    @ViewBuilder
    private var content: some View {
        if model.filteredSpaces.isEmpty && model.searchText.isEmpty {
            emptyStateView
        } else if model.filteredSpaces.isNotEmpty {
            scrollView
        } else {
            SpaceHubSearchEmptySpaceView()
        }
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: vaultBackToRootsToggle ? 8 : 0) {
                HomeUpdateSubmoduleView().padding(8)

                ForEach(model.filteredSpaces) {
                    spaceCard($0)
                }
                
                Spacer.fixedHeight(40)
            }
        }
        .animation(.default, value: model.filteredSpaces)
    }
    
    private var emptyStateView: some View {
        SpaceHubEmptyStateView {
            model.onTapCreateSpace()
        }
    }
    
    private func spaceCard(_ space: ParticipantSpaceViewDataWithPreview) -> some View {
        SpaceCard(
            spaceData: space,
            wallpaper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
            draggedSpace: $draggedSpace,
            onTap: {
                model.onSpaceTap(spaceId: space.spaceView.targetSpaceId)
            },
            onTapCopy: {
                model.copySpaceInfo(spaceView: space.spaceView)
            },
            onTapMute: {
                model.muteSpace(spaceView: space.spaceView)
            },
            onTapPin: {
                try await model.pin(spaceView: space.spaceView)
            },
            onTapUnpin: {
                try await model.unpin(spaceView: space.spaceView)
            },
            onTapSettings: {
                model.openSpaceSettings(spaceId: space.spaceView.targetSpaceId)
            },
            onTapDelete: {
                model.onDeleteSpace(spaceId: space.spaceView.targetSpaceId)
            }
        )
        .equatable()
        .padding(.horizontal, vaultBackToRootsToggle ? 16 : 0)
        .if(space.spaceView.isPinned) {
            $0.onDrop(
                of: [.text],
                delegate:  SpaceHubDropDelegate(
                    destinationItem: space,
                    allSpaces: $model.spaces,
                    draggedItem: $draggedSpace,
                    initialIndex: $draggedInitialIndex
                )
            )
        }
    }
}

import SwiftUI
import AnytypeCore

// Is part of main view SpaceHubView. Related from SpaceHubViewModel
struct SpaceHubList: View {
    
    @Bindable var model: SpaceHubViewModel
    
    @State private var draggedSpaceViewId: String?
    @State private var draggedInitialIndex: Int?
    @State private var vaultBackToRootsToggle = FeatureFlags.vaultBackToRoots
    
    var body: some View {
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
    
    @ViewBuilder
    private func spaceCard(_ cardModel: SpaceCardModel) -> some View {
        SpaceCard(
            model: cardModel,
            draggedSpaceViewId: $draggedSpaceViewId,
            onTap: {
                model.onSpaceTap(spaceId: cardModel.targetSpaceId)
            },
            onTapCopy: {
                model.copySpaceInfo(spaceViewId: cardModel.spaceViewId)
            },
            onTapMute: {
                model.muteSpace(spaceViewId: cardModel.spaceViewId)
            },
            onTapPin: {
                try await model.pin(spaceViewId: cardModel.spaceViewId)
            },
            onTapUnpin: {
                try await model.unpin(spaceViewId: cardModel.spaceViewId)
            },
            onTapSettings: {
                model.openSpaceSettings(spaceId: cardModel.targetSpaceId)
            },
            onTapDelete: {
                model.onDeleteSpace(spaceId: cardModel.targetSpaceId)
            }
        )
        .padding(.horizontal, vaultBackToRootsToggle ? 16 : 0)
        .onDropIf(
            cardModel.isPinned,
            of: [.text],
            delegate: SpaceHubDropDelegate(
                destinationSpaceViewId: cardModel.spaceViewId,
                allSpaces: $model.spaces,
                draggedSpaceViewId: $draggedSpaceViewId,
                initialIndex: $draggedInitialIndex
            )
        )
        .id(cardModel.id)
    }
}

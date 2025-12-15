import SwiftUI
import AnytypeCore

// Is part of main view SpaceHubView. Related from SpaceHubViewModel
struct SpaceHubList: View {
    
    @Bindable var model: SpaceHubViewModel
    
    @State private var draggedSpaceViewId: String?
    @State private var draggedInitialIndex: Int?

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
            VStack(spacing: 8) {
                HomeUpdateSubmoduleView().padding(8)

                ForEach(model.filteredSpaces) {
                    spaceCard($0)
                }
                
                Spacer.fixedHeight(40)
            }
        }
        .animation(model.animationsEnabled ? .default : nil, value: model.filteredSpaces)
        .onAppear { DispatchQueue.main.async { model.animationsEnabled = true } }
        .onDisappear { model.animationsEnabled = false }
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
        .padding(.horizontal, 16)
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

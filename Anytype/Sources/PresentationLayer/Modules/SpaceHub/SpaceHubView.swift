import SwiftUI
import AnytypeCore
import DesignKit


struct SpaceHubView: View {
    @State private var model: SpaceHubViewModel
    @State private var draggedSpace: ParticipantSpaceViewDataWithPreview?
    @State private var draggedInitialIndex: Int?
    @State private var vaultBackToRootsToggle = FeatureFlags.vaultBackToRoots
    
    private var namespace: Namespace.ID
    
    init(output: (any SpaceHubModuleOutput)?, namespace: Namespace.ID) {
        _model = State(wrappedValue: SpaceHubViewModel(output: output))
        self.namespace = namespace
    }
    
    var body: some View {
        content
            .onAppear { model.onAppear() }
            .taskWithMemoryScope { await model.startSubscriptions() }
            .task(item: model.spaceMuteData) { data in
                await model.pushNotificationSetSpaceMode(data: data)
            }
            .homeBottomPanelHidden(true)
            .anytypeSheet(item: $model.spaceToDelete) { spaceId in
                SpaceDeleteAlert(spaceId: spaceId.value)
            }
            .handleChatCreationTip()
            .accessibilityLabel("SpaceHub")
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            if let spaces = model.spaces {
                spacesView(spaces)
            } else {
                EmptyView() // Do not show empty state view if we do not receive data yet
            }
            
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.default, value: model.spaces)
    }
    
    private func spacesView(_ spaces: [ParticipantSpaceViewDataWithPreview]) -> some View {
        NavigationStack {
            Group {
                if spaces.isEmpty {
                    emptyStateView
                } else if model.filteredSpaces.isNotEmpty {
                    scrollView
                } else {
                    SpaceHubSearchEmptySpaceView()
                }
            }
            .navigationTitle(Loc.myChannels)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .searchable(text: $model.searchText)
            .onChange(of: model.searchText) {
                model.searchTextUpdated()
            }
        }.tint(Color.Text.secondary)
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
    }
    
    private var toolbarItems: some ToolbarContent {
        SpaceHubToolbar(
            showLoading: model.showLoading,
            profileIcon: model.profileIcon,
            notificationsDenied: model.notificationsDenied,
            namespace: namespace,
            onTapCreateSpace: {
                model.onTapCreateSpace()
            },
            onTapSettings: {
                model.onTapSettings()
            }
        )
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

#Preview {
    @Previewable @Namespace var namespace
    SpaceHubView(output: nil, namespace: namespace)
}

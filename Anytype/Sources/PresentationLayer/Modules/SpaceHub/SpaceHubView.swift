import SwiftUI
import AnytypeCore
import DesignKit


struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewDataWithPreview?
    @State private var draggedInitialIndex: Int?
    
    private var namespace: Namespace.ID
    
    init(output: (any SpaceHubModuleOutput)?, namespace: Namespace.ID) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(output: output))
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
                    searchEmptyStateView
                }
            }
            .navigationTitle(Loc.myChannels)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .searchable(text: $model.searchText)
        }.tint(Color.Text.secondary)
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: FeatureFlags.vaultBackToRoots ? 8 : 0) {
                HomeUpdateSubmoduleView().padding(8)

                ForEach(model.filteredSpaces) {
                    spaceCard($0)
                }
                
                Spacer.fixedHeight(40)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ios26ToolbarItems
        } else {
            legacyToolbarItems
        }
    }
    
    @ToolbarContentBuilder
    private var legacyToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 6) {
                if model.showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer.fixedWidth(18)
                }
                
                AnytypeText(Loc.myChannels, style: .uxTitle1Semibold)
                
                Spacer.fixedWidth(18)
            }
        }
        
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                model.onTapSettings()
            } label: {
                IconView(icon: model.profileIcon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 28, height: 28)
                    .overlay(alignment: .topTrailing) {
                        if model.notificationsDenied {
                            attentionDotView
                        }
                    }
                    .padding(.vertical, 8)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            SpaceHubNewSpaceButton {
                model.onTapCreateSpace()
            }
        }
    }
    
    @available(iOS 26.0, *)
    @ToolbarContentBuilder
    private var ios26ToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 6) {
                if model.showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer.fixedWidth(18)
                }
                
                AnytypeText(Loc.myChannels, style: .uxTitle1Semibold)
                
                Spacer.fixedWidth(18)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                model.onTapSettings()
            } label: {
                IconView(icon: model.profileIcon)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 28, height: 28)
                    .overlay(alignment: .topTrailing) {
                        if model.notificationsDenied {
                            attentionDotView
                        }
                    }
                    .padding(.vertical, 8)
            }
        }
        
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
        
        ToolbarSpacer(placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            Button { model.onTapCreateSpace() } label: { Label("", systemImage: "plus") }
        }
        .matchedTransitionSource(id: "SpaceCreateTypePickerView", in: namespace)         
    }
    
    
    @ViewBuilder
    private var emptyStateView: some View {
        HomeUpdateSubmoduleView().padding(8)
        EmptyStateView(
            title: Loc.thereAreNoSpacesYet,
            subtitle: "",
            style: .withImage,
            buttonData: EmptyStateView.ButtonData(title: Loc.createSpace) {
                model.onTapCreateSpace()
            }
        )
    }
    
    @ViewBuilder
    private var searchEmptyStateView: some View {
        HomeUpdateSubmoduleView().padding(8)
        EmptyStateView(
            title: Loc.noMatchesFound,
            subtitle: "",
            style: .withImage,
            buttonData: nil
        )
    }
    
    private var attentionDotView: some View {
        Circle()
            .fill(Color.Pure.red)
            .frame(width: 6, height: 6)
            .padding([.top, .trailing], 1)
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
        .if(FeatureFlags.vaultBackToRoots) {
            $0.padding(.horizontal, 16)
        }
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

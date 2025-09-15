import SwiftUI
import AnytypeCore
import DesignKit


struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    @StateObject var spaceCreationTip = SpaceCreationTipWrapper()
    
    @State private var draggedSpace: ParticipantSpaceViewDataWithPreview?
    @State private var draggedInitialIndex: Int?
    
    init(output: (any SpaceHubModuleOutput)?) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(output: output))
    }
    
    var body: some View {
        content
            .onAppear { model.onAppear() }
            .taskWithMemoryScope { await model.startSubscriptions() }
            .task(item: model.spaceMuteData) { data in
                await model.pushNotificationSetSpaceMode(data: data)
            }
            .homeBottomPanelHidden(true)
            .snackbar(toastBarData: $model.toastBarData)
            .anytypeSheet(item: $model.spaceToDelete) { spaceId in
                SpaceDeleteAlert(spaceId: spaceId.value)
            }
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
            .navigationTitle(Loc.mySpaces)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .searchable(text: $model.searchText)
        }.tint(Color.Text.secondary)
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: FeatureFlags.vaultBackToRoots ? 8 : 0) {
                HomeUpdateSubmoduleView().padding(8)
                
                if #available(iOS 17.0, *) {
                    if FeatureFlags.anyAppBetaTip {
                        HomeAnyAppWidgetTipView()
                            .padding(.horizontal, 8)
                    }
                }
                
                ForEach(model.filteredSpaces) {
                    spaceCard($0)
                }
                
                Spacer.fixedHeight(40)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 6) {
                if model.showLoading {
                    CircleLoadingView(.Text.primary)
                        .frame(width: 18, height: 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Spacer.fixedWidth(18)
                }
                
                AnytypeText(Loc.mySpaces, style: .uxTitle1Semibold)
                
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
            Button {
                spaceCreationTip.invalidate()
                model.onTapCreateSpace()
            }
            label: {
                Image(asset: .X32.addFilled)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 32, height: 32)
                    .overlay(alignment: .bottomLeading) {
                        if spaceCreationTip.shouldDisplay {
                            AttentionDotView()
                        }
                    }
                    .padding(.vertical, 6)
            }
        }
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
    SpaceHubView(output: nil)
}

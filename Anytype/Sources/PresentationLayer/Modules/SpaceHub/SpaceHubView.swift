import SwiftUI
import AnytypeCore

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewDataWithPreview?
    @State private var draggedInitialIndex: Int?
    
    @State private var offset: CGPoint?
    
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
    }
    
    var content: some View {
        ZStack {
            mainContent
            
            VStack(spacing: 0) {
                navBar
                Spacer()
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(108) // navbar
            
            if let spaces = model.filteredSpaces, let unreadSpaces = model.filteredUnreadSpaces, spaces.isNotEmpty || unreadSpaces.isNotEmpty {
                scrollView(unread: unreadSpaces, spaces: spaces)
            } else if model.searchText.isNotEmpty {
                searchEmptyStateView
            } else if model.spaces.isNotNil {
                emptyStateView
            } else {
                EmptyView() // Do not show empty state view if we do not receive data yet
            }
            
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.default, value: model.spaces)
    }
    
    private var searchBar: some View {
        SearchBar(
            text: $model.searchText,
            focused: false,
            placeholder: Loc.search,
            shouldShowDivider: false
        ).frame(height: 60)
    }
    
    private func scrollView(unread: [ParticipantSpaceViewDataWithPreview], spaces: [ParticipantSpaceViewDataWithPreview]) -> some View {
        OffsetAwareScrollView(showsIndicators: false, offsetChanged: { offset = $0}) {
            VStack(spacing: 0) {
                HomeUpdateSubmoduleView().padding(8)
                
                if #available(iOS 17.0, *) {
                    if FeatureFlags.anyAppBetaTip {
                        HomeAnyAppWidgetTipView()
                            .padding(.horizontal, 8)
                    }
                }
                
                if unread.isNotEmpty {
                    if spaces.isNotEmpty {
                        SectionHeaderView(title: Loc.unread).padding(.horizontal, 20)
                    }
                    ForEach(unread) {
                        spaceCard($0, draggable: false)
                    }
                }
                
                if spaces.isNotEmpty {
                    if unread.isNotEmpty {
                        SectionHeaderView(title: Loc.all).padding(.horizontal, 20)
                    }
                    ForEach(spaces) {
                        spaceCard($0, draggable: true)
                    }
                }
                
                Spacer.fixedHeight(40)
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
    
    private var plusButton: some View {
        Button {
            model.onTapCreateSpace()
        } label: {
            HStack(alignment: .center) {
                Spacer()
                Image(asset: .X32.plus)
                Spacer()
            }
            .padding(.vertical, 32)
            .background(Color.Shape.tertiary)
            .cornerRadius(20, style: .continuous)
            .padding(.horizontal, 8)
        }
    }
    
    private var navBar: some View {
        VStack(spacing: 4) {
            navBarContent
            searchBar
        }
        .frame(height: 108)
        .background(applyBlur ? AnyShapeStyle(Material.ultraThinMaterial) : AnyShapeStyle(Color.Background.primary))
    }
    
    private var navBarContent: some View {
        SpaceHubNavBar(
            profileIcon: model.profileIcon,
            notificationsDenied: model.notificationsDenied,
            showLoading: model.showLoading,
            onTapSettings: {
                model.onTapSettings()
            },
            onTapCreateSpace: {
                model.onTapCreateSpace()
            }
        )
    }
    
    private func spaceCard(_ space: ParticipantSpaceViewDataWithPreview, draggable: Bool) -> some View {
        SpaceCard(
            spaceData: space,
            wallpaper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
            draggable: draggable,
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
            }
        )
        .equatable()
        .if(draggable) {
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
    
    private var applyBlur: Bool {
        offset.isNotNil && offset!.y < 0
    }
}

#Preview {
    SpaceHubView(output: nil)
}

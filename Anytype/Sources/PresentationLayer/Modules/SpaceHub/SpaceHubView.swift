import SwiftUI
import AnytypeCore

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
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
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            if let spaces = model.filteredSpaces, let unreadSpaces = model.filteredUnreadSpaces {
                spacesView(spaces: spaces, unreadSpaces: unreadSpaces)
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
    
    private func spacesView(spaces: [ParticipantSpaceViewDataWithPreview], unreadSpaces: [ParticipantSpaceViewDataWithPreview], ) -> some View {
        NavigationStack {
            Group {
                if spaces.isNotEmpty || unreadSpaces.isNotEmpty {
                    scrollView(spaces: spaces, unreadSpaces: unreadSpaces)
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
    
    private func scrollView(spaces: [ParticipantSpaceViewDataWithPreview], unreadSpaces: [ParticipantSpaceViewDataWithPreview]) -> some View {
        ScrollView {
            VStack(spacing: FeatureFlags.vaultBackToRoots ? 8 : 0) {
                HomeUpdateSubmoduleView().padding(8)
                
                if #available(iOS 17.0, *) {
                    if FeatureFlags.anyAppBetaTip {
                        HomeAnyAppWidgetTipView()
                            .padding(.horizontal, 8)
                    }
                }
                
                if unreadSpaces.isNotEmpty {
                    if spaces.isNotEmpty {
                        SectionHeaderView(title: Loc.unread).padding(.horizontal, 20)
                    }
                    ForEach(unreadSpaces) {
                        spaceCard($0, draggable: false)
                    }
                }
                
                if spaces.isNotEmpty {
                    if unreadSpaces.isNotEmpty {
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
                model.onTapCreateSpace()
            }
            label: {
                Image(asset: .X32.addFilled)
                    .foregroundStyle(Color.Control.secondary)
                    .frame(width: 32, height: 32)
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
    
    private var attentionDotView: some View {
        Circle()
            .fill(Color.Pure.red)
            .frame(width: 6, height: 6)
            .padding([.top, .trailing], 1)
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
        .if(FeatureFlags.vaultBackToRoots) {
            $0.padding(.horizontal, 16)
        }
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
}

#Preview {
    SpaceHubView(output: nil)
}

import SwiftUI
import AnytypeCore

struct NewSpaceHubView: View {
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
            .task { await model.startSubscriptions() }
            
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
            .anytypeSheet(item: $model.spaceIdToLeave) {
                SpaceLeaveAlert(spaceId: $0.value)
            }
            .anytypeSheet(item: $model.spaceIdToDelete) {
                SpaceDeleteAlert(spaceId: $0.value)
            }
            .homeBottomPanelHidden(true)
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
            if let spaces = model.spaces, let unreadSpaces = model.unreadSpaces, spaces.isNotEmpty || unreadSpaces.isNotEmpty {
                scrollView(unread: unreadSpaces, spaces: spaces)
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
    
    private func scrollView(unread: [ParticipantSpaceViewDataWithPreview], spaces: [ParticipantSpaceViewDataWithPreview]) -> some View {
        OffsetAwareScrollView(showsIndicators: false, offsetChanged: { offset = $0}) {
            VStack(spacing: 0) {
                Spacer.fixedHeight(44) // navbar
                HomeUpdateSubmoduleView().padding(8)
                
                if #available(iOS 17.0, *) {
                    if FeatureFlags.anyAppBetaTip {
                        HomeAnyAppWidgetTipView()
                            .padding(.horizontal, 8)
                    }
                }
                
                if unread.isNotEmpty {
                    SectionHeaderView(title: "Unread").padding(.horizontal, 20)
                    ForEach(unread) {
                        spaceCard($0, draggable: false)
                    }
                }
                
                if spaces.isNotEmpty {
                    if FeatureFlags.unreadOnHome {
                        SectionHeaderView(title: "All").padding(.horizontal, 20)
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
        Spacer.fixedHeight(44) // navbar
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
        HStack(alignment: .center, spacing: 0) {
            Button { model.showSettings = true }
            label: {
                IconView(icon: model.profileIcon)
                    .foregroundStyle(Color.Control.active)
                    .frame(width: 28, height: 28)
                    .padding(.vertical, 8)
            }
            
            Spacer()
            AnytypeText(FeatureFlags.spaceHubNewTitle ? Loc.myChannels : Loc.mySpaces, style: .uxTitle1Semibold)
            Spacer()
            
            Button { model.onTapCreateSpace() }
            label: {
                Image(asset: .X32.addFilled)
                    .foregroundStyle(Color.Control.active)
                    .frame(width: 32, height: 32)
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .if(offset.isNotNil && offset!.y < 0, if: {
            $0.background(Material.ultraThinMaterial)
        }, else: {
            $0.background(Color.Background.primary)
        })
        .frame(height: 44)
    }
    
    private func spaceCard(_ space: ParticipantSpaceViewDataWithPreview, draggable: Bool) -> some View {
        NewSpaceCard(
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
            onTapLeave: {
                model.leaveSpace(spaceId: space.spaceView.targetSpaceId)
            },
            onTapDelete: {
                try await model.deleteSpace(spaceId: space.spaceView.targetSpaceId)
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
}

#Preview {
    NewSpaceHubView(output: nil)
}

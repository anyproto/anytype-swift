import SwiftUI
import AnytypeCore

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewData?
    @State private var draggedInitialIndex: Int?
    
    init(sceneId: String, output: (any SpaceHubModuleOutput)?) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(sceneId: sceneId, output: output))
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
        VStack(spacing: 0) {
            navBar
            HomeUpdateSubmoduleView().padding(8)
            
            if let spaces = model.spaces {
                VStack(spacing: 8) {
                    ScrollView {
                        Spacer.fixedHeight(4)
                        if #available(iOS 17.0, *) {
                            if FeatureFlags.anyAppBetaTip {
                                HomeAnyAppWidgetTipView()
                                    .padding(.horizontal, 8)
                            }
                        }
                        ForEach(spaces) {
                            spaceCard($0)
                        }
                        if model.createSpaceAvailable {
                            plusButton
                        }
                        Spacer.fixedHeight(40)
                    }
                    .scrollIndicators(.never)
                }
            }
            
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.default, value: model.spaces)
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
            Spacer()
            AnytypeText(FeatureFlags.spaceHubNewTitle ? Loc.myChannels : Loc.mySpaces, style: .uxTitle1Semibold)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .leading) {
            Button(
                action: {
                    model.showSettings = true
                },
                label: {
                    IconView(icon: model.profileIcon)
                        .foregroundStyle(Color.Control.active)
                        .frame(width: 28, height: 28)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
            )
        }
        .if(model.showPlusInNavbar) {
            $0.overlay(alignment: .trailing) {
                Button(
                    action: {
                        model.onTapCreateSpace()
                    },
                    label: {
                        Image(asset: .X32.plus)
                            .foregroundStyle(Color.Control.active)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                    }
                )
            }
        }
    }
    
    private func spaceCard(_ space: ParticipantSpaceViewData) -> some View {
        Button {
            model.onSpaceTap(spaceId: space.spaceView.targetSpaceId)
        } label: {
            spaceCardLabel(space)
        }
        .disabled(space.spaceView.isLoading)
        .contextMenu { menuItems(space: space) }
        .padding(.horizontal, 8)
        .onDrop(
            of: [.text],
            delegate:  SpaceHubDropDelegate(
                destinationItem: space,
                allSpaces: $model.spaces,
                draggedItem: $draggedSpace,
                initialIndex: $draggedInitialIndex
            )
        )
    }
    
    private func spaceCardLabel(_ space: ParticipantSpaceViewData) -> some View {
        HStack(spacing: 16) {
            IconView(icon: space.spaceView.objectIconImage)
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 6) {
                AnytypeText(space.spaceView.name.withPlaceholder, style: .bodySemibold).lineLimit(1)
                if FeatureFlags.spaceUxTypes {
                    AnytypeText(space.spaceView.uxType.name, style: .relation3Regular)
                        .lineLimit(1)
                        .opacity(0.6)
                } else {
                    AnytypeText(space.spaceView.spaceAccessType?.name ?? "", style: .relation3Regular)
                        .lineLimit(1)
                        .opacity(0.6)
                }
                Spacer.fixedHeight(1)
            }
            
            Spacer()
            
            if space.spaceView.isLoading && FeatureFlags.newSpacesLoading {
                DotsView().frame(width: 30, height: 6)
            } else if space.spaceView.unreadMessagesCount > 0 {
                CounterView(count: space.spaceView.unreadMessagesCount)
            } else if space.spaceView.isPinned {
                Image(asset: .X24.pin).frame(width: 22, height: 22)
            }
        }
        .padding(16)
        .background(
            DashboardWallpaper(
                mode: .spaceHub,
                wallpaper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
                spaceIcon: space.spaceView.iconImage
            )
        )
        .cornerRadius(20, style: .continuous)
        
        .if(space.spaceView.isLoading && !FeatureFlags.newSpacesLoading) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview, .contextMenuPreview], RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .if(!FeatureFlags.pinnedSpaces || space.spaceView.isPinned) {
            $0.onDrag {
                draggedSpace = space
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
        }
    }
    
    private func menuItems(space: ParticipantSpaceViewData) -> some View {
        Group {
            if space.spaceView.isLoading {
                Button { model.copySpaceInfo(spaceView: space.spaceView) } label: {
                    Text(Loc.copySpaceInfo)
                }
            } else if FeatureFlags.pinnedSpaces {
                if space.spaceView.isPinned {
                    AsyncButton { try await model.unpin(spaceView: space.spaceView) } label: {
                        Text(Loc.unpin)
                    }
                } else {
                    AsyncButton { try await model.pin(spaceView: space.spaceView) } label: {
                        Text(Loc.pin)
                    }
                }
            }
            
            Divider()
            if space.canLeave {
                Button(role: .destructive) {
                    model.leaveSpace(spaceId: space.spaceView.targetSpaceId)
                } label: {
                    Text(Loc.leaveASpace)
                }
            }
            if space.canBeDeleted {
                AsyncButton(role: .destructive) {
                    try await model.deleteSpace(spaceId: space.spaceView.targetSpaceId)
                } label: {
                    Text(Loc.delete)
                }
            }
        }
    }
}

#Preview {
    SpaceHubView(sceneId: "1337", output: nil)
}

import SwiftUI
import AnytypeCore

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewData?
    @State private var draggedInitialIndex: Int?
    
    @State private var size = CGSizeZero
    
    init(sceneId: String) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(sceneId: sceneId))
    }
    
    var body: some View {
        content
            .readSize { size = $0 }
            .onAppear {
                model.onAppear()
            }
            .sheet(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(sceneId: model.sceneId, output: model)
            }
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            navBar
            
            if let spaces = model.spaces {
                VStack(spacing: 8) {
                    ScrollView {
                        Spacer.fixedHeight(4)
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
            model.showSpaceCreate.toggle()
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
            AnytypeText(Loc.mySpaces, style: .uxTitle1Semibold)
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
                    Image(asset: .NavigationBase.settings)
                        .foregroundStyle(Color.Button.active)
                        .frame(width: 22, height: 22)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 26)
                }
            )
        }
        .if(model.showPlusInNavbar) {
            $0.overlay(alignment: .trailing) {
                Button(
                    action: {
                        model.showSpaceCreate = true
                    },
                    label: {
                        Image(asset: .X32.plus)
                            .foregroundStyle(Color.Button.active)
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
        .contextMenu {
            if space.spaceView.isLoading {
                debugMenuItems(spaceView: space.spaceView)
            }
        }
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
                AnytypeText(space.spaceView.spaceAccessType?.name ?? "", style: .relation3Regular)
                    .lineLimit(1)
                    .opacity(0.6)
                Spacer.fixedHeight(1)
            }
            Spacer()
        }
        .padding(16)
        .background(
            DashboardWallpaper(
                mode: FeatureFlags.spaceHubParallax ? .parallax(containerHeight: size.height) : .spaceHub,
                wallpaper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
                spaceIcon: space.spaceView.iconImage
            )
        )
        .cornerRadius(20, style: .continuous)
        .if(space.spaceView.isLoading) { $0.redacted(reason: .placeholder) }
        .contentShape([.dragPreview], RoundedRectangle(cornerRadius: 20))
        .onDrag {
            draggedSpace = space
            return NSItemProvider()
        }
        .padding(.horizontal, 8)
    }
    
    private func debugMenuItems(spaceView: SpaceView) -> some View {
        Group {
            Button {
                model.copySpaceInfo(spaceView: spaceView)
            } label: {
                Label(Loc.copySpaceInfo, systemImage: "info.windshield")
            }
            
            Button(role: .destructive) {
                model.deleteSpace(spaceId: spaceView.targetSpaceId)
            } label: {
                Label(Loc.delete, systemImage: "figure.australian.football")
            }
        }
    }
}

#Preview {
    SpaceHubView(sceneId: "1337")
}

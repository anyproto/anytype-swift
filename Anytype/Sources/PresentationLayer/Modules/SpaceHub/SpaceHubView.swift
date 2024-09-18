import SwiftUI

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    @State private var draggedSpace: ParticipantSpaceViewData?
    @State private var draggedInitialIndex: Int?
    
    init(sceneId: String) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(sceneId: sceneId))
    }
    
    var body: some View {
        content
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
                        ForEach(spaces) {
                            spaceCard($0)
                        }
                        plusButton
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
            AnytypeText("My spaces", style: .uxTitle1Semibold)
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
        .onDrag {
            draggedSpace = space
            return NSItemProvider()
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
                AnytypeText(space.spaceView.name, style: .bodySemibold).lineLimit(1)
                AnytypeText(space.spaceView.spaceAccessType?.name ?? "", style: .relation3Regular)
                    .lineLimit(1)
                    .opacity(0.6)
                Spacer.fixedHeight(2)
            }
            Spacer()
        }
        .padding(16)
        .background(
            DashboardWallpaper(
                wallpaper: model.wallpapers[space.spaceView.targetSpaceId] ?? .default,
                spaceIcon: space.spaceView.iconImage
            )
        )
        .cornerRadius(20, style: .continuous)
        .padding(.horizontal, 8)
        .if(space.spaceView.isLoading) { $0.redacted(reason: .placeholder) }
    }
}

#Preview {
    SpaceHubView(sceneId: "1337")
}

import SwiftUI

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    init(showActiveSpace: @escaping () -> Void) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(showActiveSpace: showActiveSpace))
    }
    
    var body: some View {
        content
            .sheet(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(output: model)
            }
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
    }
    
    var content: some View {
        VStack(spacing: 8) {
            navBar
            
            if let spaces = model.spaces {
                ScrollView {
                    ForEach(spaces) {
                        spaceCard($0)
                    }
                    plusButton
                }
                .scrollIndicators(.never)
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
        .padding(.vertical, 8)
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
            HStack(spacing: 16) {
                IconView(icon: space.spaceView.objectIconImage)
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 6) {
                    AnytypeText(space.spaceView.name, style: .bodySemibold)
                    AnytypeText(space.spaceView.spaceAccessType?.name ?? "", style: .relation3Regular)
                }
                Spacer()
            }
            .padding(16)
            .background(UserDefaultsConfig.wallpaper(spaceId: space.spaceView.targetSpaceId).asView.opacity(0.3))
            .cornerRadius(20, style: .continuous)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    SpaceHubView { }
}

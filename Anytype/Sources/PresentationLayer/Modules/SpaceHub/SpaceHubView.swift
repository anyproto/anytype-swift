import SwiftUI

struct SpaceHubView: View {
    @StateObject private var model: SpaceHubViewModel
    
    init(onTap: @escaping () -> Void) {
        _model = StateObject(wrappedValue: SpaceHubViewModel(onTap: onTap))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            navBar
            
            ForEach(model.spaces) {
                spaceCard($0)
            }
            .animation(.default, value: model.spaces)
            
            Spacer()
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
                    // TODO
                },
                label: {
                    Image(asset: .NavigationBase.settings)
                        .frame(width: 22, height: 22)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 26)
                }
            )
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
            .background(Color.Light.amber.gradient)
            .cornerRadius(20, style: .continuous)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    SpaceHubView { }
}

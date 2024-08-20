import SwiftUI

struct SpaceHubView: View {
    private let onTap: () -> ()
    
    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 8) {
            navBar
            
            spaceCard()
            spaceCard()
            spaceCard()
            spaceCard()
            spaceCard()
            
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
    
    private func spaceCard() -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                Image(asset: .AppIconsPreview.appIconSmile)
                    .frame(width: 64, height: 64)
                    .cornerRadius(8, style: .circular)
                VStack(alignment: .leading, spacing: 6) {
                    AnytypeText("Space name", style: .bodySemibold)
                    AnytypeText("Space type", style: .relation3Regular)
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

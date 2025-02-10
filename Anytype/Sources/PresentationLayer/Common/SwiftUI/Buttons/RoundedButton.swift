import SwiftUI

enum RoundedButtonDecoration {
    case badge(Int)
}

struct RoundedButton: View {
    
    let text: String
    let icon: ImageAsset?
    let decoration: RoundedButtonDecoration?
    let action: () -> Void
    
    init(text: String, icon: ImageAsset? = nil, decoration: RoundedButtonDecoration? = nil, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.decoration = decoration
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                if let icon {
                    IconView(asset: icon).frame(width: 24, height: 24)
                    Spacer.fixedWidth(8)
                }
                AnytypeText(text, style: .previewTitle1Regular)
                Spacer()
                decorationView
                IconView(asset: .X24.Arrow.right).frame(width: 24, height: 24)
            }
            .padding(20)
            .border(12, color: .Shape.primary, lineWidth: 0.5)
        }
    }
    
    @ViewBuilder
    var decorationView: some View {
        switch decoration {
        case .badge(let count):
            AnytypeText("\(count)", style: .caption1Regular)
                .foregroundColor(.Control.white)
                .padding(.horizontal, 5)
                .background(Capsule().fill(Color.Control.transparentActive))
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    RoundedButton(text: "ClickMe", icon: .X24.member, decoration: .badge(445)) { }
}

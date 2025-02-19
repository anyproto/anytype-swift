import SwiftUI
import Services


enum RoundedButtonDecoration {
    case badge(Int)
    case objectType(ObjectType)
    
    init?(objectType: ObjectType?) {
        guard let objectType else { return nil }
        self = .objectType(objectType)
    }
}

struct RoundedButton: View {
    
    let text: String
    let textColor: Color
    let icon: ImageAsset?
    let decoration: RoundedButtonDecoration?
    let action: () -> Void
    
    init(_ text: String, textColor: Color = .Text.primary, icon: ImageAsset? = nil, decoration: RoundedButtonDecoration? = nil, action: @escaping () -> Void) {
        self.text = text
        self.textColor = textColor
        self.icon = icon
        self.decoration = decoration
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                if let icon {
                    Image(asset: icon)
                        .renderingMode(.template)
                        .foregroundStyle(Color.Text.primary)
                        .frame(width: 24, height: 24)
                    Spacer.fixedWidth(8)
                }
                AnytypeText(text, style: .previewTitle1Regular).foregroundColor(textColor)
                Spacer()
                decorationView
                Spacer.fixedWidth(8)
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
        case let .objectType(objectType):
            HStack(spacing: 8) {
                IconView(objectType: objectType).frame(width: 20, height: 20)
                AnytypeText(objectType.name, style: .previewTitle1Regular)
            }
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    RoundedButton("ClickMe", icon: .X24.member, decoration: .badge(445)) { }
}

import SwiftUI
import Services


enum RoundedButtonDecoration {
    case chervon
    case badge(Int)
    case objectType(ObjectType)
    case toggle(isOn: Bool, onToggle: (Bool) -> Void)
    
    init?(objectType: ObjectType?) {
        guard let objectType else { return nil }
        self = .objectType(objectType)
    }
}

struct RoundedButtonView: View {
    
    let text: String
    let textColor: Color
    let icon: ImageAsset?
    let decoration: RoundedButtonDecoration?
    
    init(_ text: String, textColor: Color = .Text.primary, icon: ImageAsset? = nil, decoration: RoundedButtonDecoration? = nil) {
        self.text = text
        self.textColor = textColor
        self.icon = icon
        self.decoration = decoration
    }
    
    var body: some View {
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
        }
        .padding(20)
        .border(12, color: .Shape.primary, lineWidth: 0.5)
    }
    
    @ViewBuilder
    var decorationView: some View {
        switch decoration {
        case .chervon:
            Spacer.fixedWidth(8)
            IconView(asset: .X24.Arrow.right).frame(width: 24, height: 24)
        case .badge(let count):
            AnytypeText("\(count)", style: .caption1Regular)
                .foregroundColor(.Control.white)
                .padding(.horizontal, 5)
                .background(Capsule().fill(Color.Control.transparentActive))
            Spacer.fixedWidth(8)
            IconView(asset: .X24.Arrow.right).frame(width: 24, height: 24)
        case let .objectType(objectType):
            HStack(spacing: 8) {
                IconView(objectType: objectType).frame(width: 20, height: 20)
                AnytypeText(objectType.name, style: .previewTitle1Regular)
            }
            Spacer.fixedWidth(8)
            IconView(asset: .X24.Arrow.right).frame(width: 24, height: 24)
        case let .toggle(isOn, onToggle):
            AnytypeToggle(title: "", isOn: isOn) { onToggle($0) }
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    RoundedButtonView("ClickMe", icon: .X24.member, decoration: .badge(445))
}

import SwiftUI
import Services


enum RoundedButtonDecoration {
    case chervon
    case caption(String)
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
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .border(16, color: .Shape.primary, lineWidth: 0.5)
    }
    
    @ViewBuilder
    var decorationView: some View {
        switch decoration {
        case .chervon:
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case .caption(let caption):
            AnytypeText(caption, style: .bodyRegular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case let .objectType(objectType):
            HStack(spacing: 8) {
                IconView(object: objectType.icon).frame(width: 20, height: 20)
                AnytypeText(objectType.name, style: .previewTitle1Regular)
            }
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case let .toggle(isOn, onToggle):
            AnytypeToggle(title: "", isOn: isOn) { onToggle($0) }
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    RoundedButtonView("ClickMe", icon: .X24.member, decoration: .caption("445"))
}

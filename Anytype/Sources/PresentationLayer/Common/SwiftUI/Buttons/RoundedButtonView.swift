import SwiftUI
import Services


enum RoundedButtonDecoration {
    case chevron
    case caption(String)
    case badge(Int)
    case alert
    case objectType(ObjectType)
    case object(icon: Icon?, name: String)
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

    var hasIcon: Bool { icon != nil }

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
                    .frame(width: 20, height: 20)
                Spacer.fixedWidth(12)
            }
            AnytypeText(text, style: .bodySemibold).foregroundStyle(textColor)
            Spacer()
            decorationView
        }
    }
    
    @ViewBuilder
    var decorationView: some View {
        switch decoration {
        case .chevron:
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case .caption(let caption):
            AnytypeText(caption, style: .bodyRegular)
                .foregroundStyle(Color.Text.secondary)
                .lineLimit(1)
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case .badge(let badge):
            CounterView(count: badge, style: .highlighted)
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case .alert:
            AnytypeText("!", style: .caption1Regular)
                .foregroundStyle(Color.Control.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.Pure.red))
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case let .objectType(objectType):
            HStack(spacing: 8) {
                IconView(object: objectType.icon).frame(width: 20, height: 20)
                AnytypeText(objectType.name, style: .bodyRegular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
            }
            Spacer.fixedWidth(8)
            IconView(asset: .RightAttribute.disclosure).frame(width: 24, height: 24)
        case let .object(icon, name):
            HStack(spacing: 8) {
                IconView(icon: icon).frame(width: 20, height: 20)
                AnytypeText(name, style: .bodyRegular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)
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
    SettingsSection {
        RoundedButtonView("Members", icon: .X24.member, decoration: .chevron)
            .settingsRow(showDivider: true, leadingPadding: 48)
        RoundedButtonView("Notifications", icon: .X24.unmuted, decoration: .caption("All"))
            .settingsRow(showDivider: false, leadingPadding: 48)
    }
    .padding()
}

import SwiftUI

extension SettingsSectionItemView {
    enum Decoration {
        case arrow(text: String = "")
        case button(text: String)
    }
}

struct SettingsSectionItemView: View {
    let name: String
    let iconImage: Icon?
    let decoration: Decoration?
    let showDivider: Bool
    let onTap: () -> Void
        
    init(name: String, imageAsset: ImageAsset, decoration: Decoration? = .arrow(), showDivider: Bool = true, onTap: @escaping () -> Void) {
        self.name = name
        self.iconImage = .asset(imageAsset)
        self.decoration = decoration
        self.showDivider = showDivider
        self.onTap = onTap
    }
    
    init(name: String, iconImage: Icon? = nil, decoration: Decoration? = .arrow(), showDivider: Bool = true, onTap: @escaping () -> Void) {
        self.name = name
        self.iconImage = iconImage
        self.decoration = decoration
        self.showDivider = showDivider
        self.onTap = onTap
    }
    
    private let iconWidth: CGFloat = 28
    private let iconSpacing: CGFloat = 12

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 0) {
                if let iconImage {
                    IconView(icon: iconImage)
                        .frame(width: iconWidth, height: iconWidth)
                    Spacer.fixedWidth(iconSpacing)
                }
                HStack(alignment: .center, spacing: 0) {
                    AnytypeText(name, style: .uxBodyRegular)
                        .dynamicForegroundStyle(color: .Text.primary, disabledColor: .Text.tertiary)
                    Spacer()
                    decorationView
                }
                .frame(maxHeight: .infinity)
                .if(showDivider) { $0.newDivider() }
            }
        }
        .frame(height: 52)
    }
    
    var decorationView: some View {
        Group {
            switch decoration {
            case .arrow(let text):
                HStack(alignment: .center, spacing: 10) {
                    AnytypeText(text, style: .bodyRegular)
                        .dynamicForegroundStyle(color: .Text.secondary, disabledColor: .Text.tertiary)
                        .lineLimit(1)
                    Image(asset: .RightAttribute.disclosure)
                        .renderingMode(.template)
                        .dynamicForegroundStyle(color: .Control.active, disabledColor: .Control.inactive)
                }
            case .button(let text):
                AnytypeText(text, style: .caption1Medium)
                    .foregroundColor(.Text.inversion)
                    .lineLimit(1)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(Color.Control.button)
                    .cornerRadius(6, style: .continuous)
            case .none:
                EmptyView()
            }
        }
    }
}

struct SettingsSectionItemView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            SettingsSectionItemView(name: "Keychain", imageAsset: .Settings.pinCode, onTap: {})
            SettingsSectionItemView(name: "Membership", imageAsset: .Settings.membership, decoration: .button(text: "Join"), onTap: {})
        }.padding()
    }
}

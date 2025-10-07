import SwiftUI

extension SettingsSectionItemView {
    enum Decoration {
        case arrow(text: String = "", needAttention: Bool = false)
        case button(text: String)
    }
}

struct SettingsSectionItemView: View {
    let name: String
    let textColor: Color
    let iconImage: Icon?
    let decoration: Decoration?
    let showDivider: Bool
    let onTap: () -> Void
        
    init(name: String, textColor: Color = .Text.primary, imageAsset: ImageAsset, decoration: Decoration? = .arrow(), showDivider: Bool = true, onTap: @escaping () -> Void) {
        self.name = name
        self.textColor = textColor
        self.iconImage = .asset(imageAsset)
        self.decoration = decoration
        self.showDivider = showDivider
        self.onTap = onTap
    }
    
    init(name: String, textColor: Color = .Text.primary, iconImage: Icon? = nil, decoration: Decoration? = .arrow(), showDivider: Bool = true, onTap: @escaping () -> Void) {
        self.name = name
        self.textColor = textColor
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
                    Text(name)
                        .anytypeStyle(.uxBodyRegular)
                        .dynamicForegroundStyle(color: textColor, disabledColor: .Text.tertiary)
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
            case .arrow(let text, let needAttention):
                HStack(alignment: .center, spacing: 12) {
                    if needAttention {
                        Image(asset: .X18.redAttention)
                    }
                    if text.isNotEmpty {
                        Text(text)
                            .anytypeStyle(.bodyRegular)
                            .dynamicForegroundStyle(color: .Text.secondary, disabledColor: .Text.tertiary)
                            .lineLimit(1)
                    }
                    Image(asset: .RightAttribute.disclosure)
                        .renderingMode(.template)
                        .dynamicForegroundStyle(color: .Control.secondary, disabledColor: .Control.tertiary)
                }
            case .button(let text):
                AnytypeText(text, style: .caption1Medium)
                    .foregroundColor(.Text.inversion)
                    .lineLimit(1)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(Color.Control.accent100)
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
            SettingsSectionItemView(name: "Keychain", imageAsset: .Settings.appearance, onTap: {})
            SettingsSectionItemView(name: "Membership", imageAsset: .Settings.membership, decoration: .button(text: "Join"), onTap: {})
        }.padding()
    }
}

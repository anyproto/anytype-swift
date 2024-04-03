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
    let onTap: () -> Void
        
    init(name: String, imageAsset: ImageAsset, decoration: Decoration? = .arrow(), onTap: @escaping () -> Void) {
        self.name = name
        self.iconImage = .asset(imageAsset)
        self.decoration = decoration
        self.onTap = onTap
    }
    
    init(name: String, iconImage: Icon? = nil, decoration: Decoration? = .arrow(), onTap: @escaping () -> Void) {
        self.name = name
        self.iconImage = iconImage
        self.decoration = decoration
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
                    AnytypeText(name, style: .uxBodyRegular, color: .Text.primary)
                    Spacer()
                    decorationView
                }
                .frame(maxHeight: .infinity)
                .newDivider()
            }
        }
        .frame(height: 52)
    }
    
    var decorationView: some View {
        Group {
            switch decoration {
            case .arrow(let text):
                HStack(alignment: .center, spacing: 10) {
                    AnytypeText(text, style: .bodyRegular, color: .Text.secondary)
                        .lineLimit(1)
                    Image(asset: .arrowForward)
                        .renderingMode(.template)
                        .foregroundColor(.Text.tertiary)
                }
            case .button(let text):
                AnytypeText(text, style: .caption1Medium, color: .Text.labelInversion)
                    .lineLimit(1)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(Color.Button.button)
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

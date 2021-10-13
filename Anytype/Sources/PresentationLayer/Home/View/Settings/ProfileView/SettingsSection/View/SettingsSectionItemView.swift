import SwiftUI

struct SettingsSectionItemView: View {
    let name: String
    let icon: Image
    let comingSoon: Bool
    
    @Binding var pressed: Bool
    
    private let iconWidth: CGFloat = 28
    private let iconSpacing: CGFloat = 12

    var body: some View {
        Button(action: { pressed = true }) {
            HStack(alignment: .center, spacing: 0) {
                icon.imageScale(.large).frame(width: iconWidth, height: iconWidth)
                Spacer.fixedWidth(iconSpacing)
                AnytypeText(name, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                if comingSoon {
                    AnytypeText("Soon".localized, style: .uxCalloutRegular, color: .textTertiary)
                } else {
                    Image.arrow
                }
            }
        }
        .disabled(comingSoon)
        .modifier(
            DividerModifier(
                spacing: 12,
                leadingPadding: iconWidth + iconSpacing
            )
        )
    }
}

struct SettingsSectionItemView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsSectionItemView(name: "keychain", icon: Image.settings.pin, comingSoon: false, pressed: .constant(false))
    }
}

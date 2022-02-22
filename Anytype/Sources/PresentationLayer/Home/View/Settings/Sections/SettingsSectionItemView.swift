import SwiftUI

struct SettingsSectionItemView: View {
    let name: String
    let icon: Image
    
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
                Image.arrow
                    .renderingMode(.template)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(height: 52)
        .divider(leadingPadding: iconWidth + iconSpacing)
    }
}

struct SettingsSectionItemView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsSectionItemView(name: "keychain", icon: Image.settings.pin, pressed: .constant(false))
    }
}

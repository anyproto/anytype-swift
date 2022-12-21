import SwiftUI

struct SettingsSectionItemView: View {
    let name: String
    let imageAsset: ImageAsset
    
    @Binding var pressed: Bool
    
    private let iconWidth: CGFloat = 28
    private let iconSpacing: CGFloat = 12

    var body: some View {
        Button(action: { pressed = true }) {
            HStack(alignment: .center, spacing: 0) {
                Image(asset: imageAsset).imageScale(.large).frame(width: iconWidth, height: iconWidth)
                Spacer.fixedWidth(iconSpacing)
                AnytypeText(name, style: .uxBodyRegular, color: .TextNew.primary)
                Spacer()
                Image(asset: .arrowForward)
                    .renderingMode(.template)
                    .foregroundColor(.TextNew.tertiary)
            }
        }
        .frame(height: 52)
        .divider(leadingPadding: iconWidth + iconSpacing)
    }
}

struct SettingsSectionItemView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsSectionItemView(name: "keychain", imageAsset: .settingsSetPinCode, pressed: .constant(false))
    }
}

import SwiftUI

struct SettingsSectionItemView: View {
    let name: String
    let iconImage: ObjectIconImage?
    let onTap: () -> Void
        
    init(name: String, imageAsset: ImageAsset, onTap: @escaping () -> Void) {
        self.name = name
        self.iconImage = .imageAsset(imageAsset)
        self.onTap = onTap
    }
    
    init(name: String, iconImage: ObjectIconImage? = nil, onTap: @escaping () -> Void) {
        self.name = name
        self.iconImage = iconImage
        self.onTap = onTap
    }
    
    private let iconWidth: CGFloat = 28
    private let iconSpacing: CGFloat = 12

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 0) {
                if let iconImage {
                    SwiftUIObjectIconImageView(iconImage: iconImage, usecase: .settingsSection)
                        .frame(width: iconWidth, height: iconWidth)
                    Spacer.fixedWidth(iconSpacing)
                }
                HStack(alignment: .center, spacing: 0) {
                    AnytypeText(name, style: .uxBodyRegular, color: .Text.primary)
                    Spacer()
                    Image(asset: .arrowForward)
                        .renderingMode(.template)
                        .foregroundColor(.Text.tertiary)
                }
                .frame(maxHeight: .infinity)
                .newDivider()
            }
        }
        .frame(height: 52)
    }
}

struct SettingsSectionItemView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsSectionItemView(name: "keychain", imageAsset: .Settings.pinCode, onTap: {})
    }
}

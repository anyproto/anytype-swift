import SwiftUI

struct ObjectSettingRow: View {
    
    let setting: ObjectSetting
    let isLast: Bool
    let onTap: () -> Void
    
    var body: some View {
        settingButton
            .if(!isLast) { settingButton in
                settingButton.divider(
                    spacing:  Constants.verticalInset,
                    leadingPadding: Constants.space + Constants.iconWidth
                )
            }
    }

    private var settingButton: some View {
        Button {
            onTap()
        }
        label: {
            HStack(spacing: Constants.space) {
                setting.image.frame(
                    width: Constants.iconWidth,
                    height: Constants.iconWidth
                )

                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(
                        setting.title,
                        style: .uxTitle2Medium,
                        color: .textPrimary
                    )

                    Spacer.fixedHeight(2)

                    AnytypeText(
                        setting.description,
                        style: .caption1Regular,
                        color: .textSecondary
                    )
                }

                Spacer()

                Image.arrow

            }
            .padding(.top, Constants.verticalInset)
        }
    }
    
    private enum Constants {
        static let verticalInset: CGFloat = 10
        static let iconWidth: CGFloat = 44
        static let space: CGFloat = 12
    }
}

private extension ObjectSetting {
    
    var title: String {
        switch self {
        case .icon:
            return "Icon".localized
        case .cover:
            return "Cover".localized
        case .layout:
            return "Layout".localized
        case .relations:
            return "Relations".localized
        }
    }
    
    var description: String {
        switch self {
        case .icon:
            return "Emoji or image for object".localized
        case .cover:
            return "Background picture".localized
        case .layout:
            return "Arrangement of objects on a canvas".localized
        case .relations:
            return "List of related objects".localized
        }
    }
    
    var image: Image {
        switch self {
        case .icon:
            return Image.ObjectSettings.icon
        case .cover:
            return Image.ObjectSettings.cover
        case .layout:
            return Image.ObjectSettings.layout
        case .relations:
            return Image.ObjectSettings.relations
        }
    }
}

struct ObjectSettingRowView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectSettingRow(setting: .layout, isLast: false) {}
    }
}

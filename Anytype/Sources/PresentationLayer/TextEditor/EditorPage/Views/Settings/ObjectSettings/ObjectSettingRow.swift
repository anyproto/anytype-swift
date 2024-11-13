import SwiftUI

struct ObjectSettingRow: View {
    
    let setting: ObjectSetting
    let isLast: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            settingButton
        }
        .if(!isLast) {
            $0.divider(leadingPadding: Constants.space + Constants.iconWidth)
        }
    }

    private var settingButton: some View {
        HStack(spacing: Constants.space) {
            Image(asset: setting.imageAsset).frame(width: Constants.iconWidth, height: Constants.iconWidth)

            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(setting.title, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)

                AnytypeText(setting.description, style: .caption1Regular)
                    .foregroundColor(.Text.secondary)
            }

            Spacer()

            Image(asset: .arrowForward)
        }
        .frame(height: 60)
    }
    
}

private extension ObjectSettingRow {
    
    enum Constants {
        static let iconWidth: CGFloat = 44
        static let space: CGFloat = 12
    }
    
}

#Preview {
    ObjectSettingRow(setting: .cover, isLast: false) {}
}

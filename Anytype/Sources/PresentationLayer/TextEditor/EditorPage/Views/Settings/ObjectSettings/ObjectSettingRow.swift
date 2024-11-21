import SwiftUI

struct ObjectSettingRow: View {
    
    let setting: ObjectSetting
    let showDivider: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            settingButton
        }
        .if(showDivider) {
            $0.divider()
        }
    }

    private var settingButton: some View {
        HStack(spacing: 12) {
            Image(asset: setting.imageAsset).frame(width: 24, height: 24)

            AnytypeText(setting.title, style: .uxTitle2Medium)
                .foregroundColor(.Text.primary)

            Spacer()

            Image(asset: .arrowForward)
        }
        .frame(height: 52)
    }
    
}

#Preview {
    VStack {
        ForEach(ObjectSetting.allCases, id:\.self) {
            ObjectSettingRow(setting: $0, showDivider: true) {}
        }
    }.padding()
}

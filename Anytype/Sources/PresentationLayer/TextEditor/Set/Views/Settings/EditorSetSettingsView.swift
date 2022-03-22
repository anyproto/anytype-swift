import SwiftUI
import BlocksModels

struct EditorSetSettingsView: View {
    @EnvironmentObject var mainModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetSettingsViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(EditorSetSetting.allCases) { setting in
                settingsButton(setting)
            }
            Spacer()
        }
        .background(Color.backgroundPrimary)
        .padding(.top, 16)
        .padding(.bottom, 13)
        .padding(.horizontal, 16)
    }
    
    private func settingsButton(_ setting: EditorSetSetting) -> some View {
        Button(action: { model.onSettingTap(setting) }) {
            VStack(spacing: 0) {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10.5)
                        .foregroundColor(.strokeTertiary)
                    setting.image
                }
                .frame(width: 52, height: 52)
                
                Spacer.fixedHeight(5)
                AnytypeText(setting.name, style: .caption2Regular, color: .textSecondary)
            }
            .frame(height: 52)
        }
    }
}

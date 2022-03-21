import SwiftUI
import BlocksModels

struct EditorSetSettingsView: View {
    @EnvironmentObject var mainModel: EditorSetViewModel
    @EnvironmentObject var model: SetViewPickerViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(EditorSetSettings.allCases) { setting in
                settingsButton(setting)
            }
            Spacer()
        }
        .background(Color.backgroundPrimary)
        .padding(.top, 16)
        .padding(.bottom, 13)
        .padding(.horizontal, 16)
    }
    
    private func settingsButton(_ setting: EditorSetSettings) -> some View {
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

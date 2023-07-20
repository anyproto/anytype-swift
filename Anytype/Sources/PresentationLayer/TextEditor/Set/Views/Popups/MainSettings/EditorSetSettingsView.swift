import SwiftUI
import Services

struct EditorSetSettingsView: View {
    @ObservedObject var model: EditorSetSettingsViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(EditorSetSetting.allCases) { setting in
                    settingsButton(setting)
                }
                Spacer()
            }
            .background(Color.Background.secondary)
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea()
    }
    
    private func settingsButton(_ setting: EditorSetSetting) -> some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            model.onSettingTap(setting)
        }) {
            VStack(spacing: 0) {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.Background.highlightedOfSelected)
                    Image(asset: setting.imageAsset)
                        .foregroundColor(.Button.active)
                }
                .frame(width: 52, height: 52)
                
                Spacer.fixedHeight(5)
                AnytypeText(setting.name, style: .caption2Regular, color: .Text.secondary)
            }
            .frame(height: 52)
        }
    }
}

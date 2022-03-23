import SwiftUI
import BlocksModels

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    
    @State private var icon = false
    
    var body: some View {
        VStack {
            AnytypeText("Settings".localized, style: .uxTitle1Semibold, color: .textPrimary)
            HStack {
                Toggle(isOn: $icon) {
                    AnytypeText("Icon".localized, style: .uxBodyRegular, color: .textPrimary)
                }
                .toggleStyle(SwitchToggleStyle(tint: .System.amber50))
            }
        }
        .background(Color.backgroundPrimary)
        .padding(20)
        
        .onAppear {
            icon = !setModel.activeView.hideIcon
        }
        .onChange(of: icon) {
            model.onShowIconChange($0)
        }
    }
}

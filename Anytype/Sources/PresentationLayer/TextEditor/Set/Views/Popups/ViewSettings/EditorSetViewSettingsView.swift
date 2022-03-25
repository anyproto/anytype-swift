import SwiftUI
import BlocksModels

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    
    var body: some View {
        VStack {
            settingsSection
            relationsSection
        }
        .background(Color.backgroundPrimary)
        .padding(20)
    }
    
    private var settingsSection: some View {
        VStack {
            AnytypeText("Settings".localized, style: .uxTitle1Semibold, color: .textPrimary)
            AnytypeToggle(title: "Icon", isOn: !setModel.activeView.hideIcon) {
                model.onShowIconChange($0)
            }
        }
    }
    
    private var relationsSection: some View {
        VStack {
            AnytypeText("Relations".localized, style: .uxTitle1Semibold, color: .textPrimary)
            
            ForEach(setModel.sortedRelations) { relation in
                HStack {
                    Toggle(isOn: .constant(relation.isVisible)) {
                        AnytypeText(relation.metadata.name.localized, style: .uxBodyRegular, color: .textPrimary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .System.amber50))
                }
            }
        }
    }
}

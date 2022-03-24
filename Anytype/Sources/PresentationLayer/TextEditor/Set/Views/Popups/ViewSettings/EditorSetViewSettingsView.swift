import SwiftUI
import BlocksModels

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    
    @State private var icon = false
    
    var body: some View {
        VStack {
            settingsSection
            relationsSection
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
    
    private var settingsSection: some View {
        VStack {
            AnytypeText("Settings".localized, style: .uxTitle1Semibold, color: .textPrimary)
            HStack {
                Toggle(isOn: $icon) {
                    AnytypeText("Icon".localized, style: .uxBodyRegular, color: .textPrimary)
                }
                .toggleStyle(SwitchToggleStyle(tint: .System.amber50))
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

import SwiftUI
import BlocksModels

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    
    var body: some View {
        VStack {
            topBar
            settingsSection
            relationsSection
        }
        .background(Color.backgroundSecondary)
        .padding(20)
    }
    
    private var topBar: some View {
        HStack(spacing: 0) {
            AnytypeText("Edit".localized, style: .uxBodyRegular, color: .buttonActive)
            Spacer()
            Button(action: model.showAddNewRelationView) {
                Image.plus
            }
        }
    }
    
    private var settingsSection: some View {
        VStack {
            Spacer.fixedHeight(12)
            AnytypeText("Settings".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            AnytypeToggle(title: "Icon", isOn: !setModel.activeView.hideIcon) {
                model.onShowIconChange($0)
            }
            .padding(.bottom, 10)
            .padding(.top, 2)
            .divider()
        }
    }
    
    private var relationsSection: some View {
        VStack {
            Spacer.fixedHeight(12)
            AnytypeText("Relations".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            ForEach(setModel.sortedRelations) { relation in
                relationRow(relation)
            }
        }
    }
    
    private func relationRow(_ relation: SetRelation) -> some View {
        HStack(spacing: 0) {
            Image(relation.metadata.format.iconName)
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(10)
            AnytypeToggle(
                title: relation.metadata.name,
                isOn: relation.isVisible
            ) {
                model.onRelationVisibleChange(relation, isVisible: $0)
            }
        }
        .padding(.bottom, 10)
        .padding(.top, 2)
        .divider()
    }
}

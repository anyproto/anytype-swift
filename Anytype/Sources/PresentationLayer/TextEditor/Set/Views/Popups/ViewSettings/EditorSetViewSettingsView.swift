import SwiftUI
import BlocksModels

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            content
                .padding(.horizontal, 20)
        }
        .background(Color.backgroundSecondary)
    
        .animation(.default, value: setModel.activeView)
        .animation(.default, value: setModel.sortedRelations)
    }
    
    private var content: some View {
        List {
            VStack(spacing: 0) {
                settingsSection
                relationsHeader
            }
            relationsSection
        }
        .environment(\.editMode, $editMode)
        
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
        
        .padding(.horizontal, -15) // list internal padding
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .buttonStyle(BorderlessButtonStyle())
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.buttonActive)
                    .environment(\.editMode, $editMode)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation { editMode = .inactive }
                    model.showAddNewRelationView()
                }) {
                    Image.plus
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText(Loc.settings, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            AnytypeToggle(title: Loc.icon, isOn: !setModel.activeView.hideIcon) {
                model.onShowIconChange($0)
            }
            .padding(.bottom, 10)
            .padding(.top, 2)
        }
    }
    
    private var relationsHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText(Loc.relations, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
        }
    }
    
    private var relationsSection: some View {
        ForEach(setModel.sortedRelations) { relation in
            relationRow(relation)
                .deleteDisabled(relation.metadata.isBundled)
        }
        .onDelete { indexes in
            model.deleteRelations(indexes: indexes)
        }
        .onMove { from, to in
            model.moveRelation(from: from, to: to)
        }
    }
    
    private func relationRow(_ relation: SetRelation) -> some View {
        HStack(spacing: 0) {
            Image(relation.metadata.format.iconName)
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(10)
            AnytypeToggle(
                title: relation.metadata.name,
                isOn: relation.option.isVisible
            ) {
                model.onRelationVisibleChange(relation, isVisible: $0)
            }
        }
        .padding(.bottom, 10)
        .padding(.top, 2)
    }
}

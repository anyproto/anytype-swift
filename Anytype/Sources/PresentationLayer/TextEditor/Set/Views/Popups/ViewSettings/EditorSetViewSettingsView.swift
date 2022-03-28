import SwiftUI
import BlocksModels

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    
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
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: model.showAddNewRelationView) {
                    Image.plus
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText("Settings".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            AnytypeToggle(title: "Icon", isOn: !setModel.activeView.hideIcon) {
                model.onShowIconChange($0)
            }
            .padding(.bottom, 10)
            .padding(.top, 2)
        }
    }
    
    private var relationsHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText("Relations".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
        }
    }
    
    private var relationsSection: some View {
        ForEach(setModel.sortedRelations) { relation in
            relationRow(relation)
        }
        .onDelete { index in
            print(index)
        }
        .onMove { indexes, index in
            print(indexes, index)
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

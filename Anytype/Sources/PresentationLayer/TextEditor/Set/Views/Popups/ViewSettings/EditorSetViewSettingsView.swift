import SwiftUI

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        NavigationView {
            content
        }
        .background(Color.backgroundSecondary)
        .navigationViewStyle(.stack)
    
        .animation(.default, value: setModel.activeView)
        .animation(.default, value: setModel.sortedRelations)
    }
    
    private var content: some View {
        List {
            if #available(iOS 15.0, *) {
                listContent
                .listRowSeparator(.hidden)
            } else {
                listContent
            }
        }
        .environment(\.editMode, $editMode)
        
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
        
        .listStyle(.plain)
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
                    Image(asset: .plus)
                }
            }
        }
    }
    
    private var listContent: some View {
        VStack(spacing: 0) {
            settingsHeader
            settingsSection
            relationsHeader
            relationsSection
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var settingsSection: some View {
        Group {
            if model.configuration.needShowAllSettings {
                iconSettings
                coverFitSettings
            } else {
                iconSettings
            }
        }
    }
    
    private var settingsHeader: some View {
        AnytypeText(Loc.settings, style: .uxTitle1Semibold, color: .textPrimary)
            .frame(height: 52)
            .divider()
    }
    
    private var iconSettings: some View {
        AnytypeToggle(
            title: model.configuration.iconSetting.title,
            isOn: !model.configuration.iconSetting.isSelected
        ) {
            model.configuration.iconSetting.onChange($0)
        }
        .frame(height: 52)
        .divider()
    }
    
    private var coverFitSettings: some View {
        AnytypeToggle(
            title: model.configuration.coverFitSetting.title,
            isOn: model.configuration.coverFitSetting.isSelected
        ) {
            model.configuration.coverFitSetting.onChange($0)
        }
        .frame(height: 52)
        .divider()
    }
    
    private var relationsHeader: some View {
        AnytypeText(Loc.relations, style: .uxTitle1Semibold, color: .textPrimary)
            .frame(height: 52)
            .divider()
    }
    
    private var relationsSection: some View {
        ForEach(model.configuration.relations) { relation in
            relationRow(relation)
                .deleteDisabled(relation.isBundled)
                .divider()
        }
        .onDelete { indexes in
            model.deleteRelations(indexes: indexes)
        }
        .onMove { from, to in
            model.moveRelation(from: from, to: to)
        }
    }
    
    private func relationRow(_ relation: EditorSetViewSettingsRelation) -> some View {
        HStack(spacing: 0) {
            Image(asset: relation.image)
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(10)
            AnytypeToggle(
                title: relation.title,
                isOn: relation.isOn
            ) {
                relation.onChange($0)
            }
        }
        .frame(height: 52)
    }
}

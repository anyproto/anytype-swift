import SwiftUI

struct EditorSetViewSettingsView: View {
    @EnvironmentObject var setModel: EditorSetViewModel
    @EnvironmentObject var model: EditorSetViewSettingsViewModel
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
        }
        .background(Color.backgroundSecondary)
        .navigationViewStyle(.stack)
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
        Group {
            VStack(spacing: 0) {
                settingsHeader
                settingsSection
                relationsHeader
            }
            relationsSection
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var settingsSection: some View {
        Group {
            if model.needShowAllSettings {
                valueSetting(with: model.cardSizeSetting)
                toggleSettings(with: model.iconSetting)
                valueSetting(with: model.imagePreviewSetting)
                toggleSettings(with: model.coverFitSetting)
            } else {
                toggleSettings(with: model.iconSetting)
            }
        }
    }
    
    private var settingsHeader: some View {
        AnytypeText(Loc.settings, style: .uxTitle1Semibold, color: .textPrimary)
            .frame(height: 52)
            .divider()
    }
    
    private func valueSetting(with model: EditorSetViewSettingsValueItem) -> some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(model.title, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                AnytypeText(model.value, style: .uxBodyRegular, color: .textSecondary)
                Spacer.fixedWidth(11)
                Image(asset: .arrowForward)
                    .renderingMode(.template)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(height: 52)
        .divider()
    }
    
    private func toggleSettings(with model: EditorSetViewSettingsToggleItem) -> some View {
        AnytypeToggle(
            title: model.title,
            isOn: model.isSelected
        ) {
            model.onChange($0)
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
        ForEach(model.relations) { relation in
            relationRow(relation)
                .divider()
                .deleteDisabled(relation.isBundled)
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

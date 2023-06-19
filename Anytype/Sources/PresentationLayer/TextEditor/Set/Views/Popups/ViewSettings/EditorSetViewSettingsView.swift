import SwiftUI

struct EditorSetViewSettingsView: View {
    @ObservedObject var model: EditorSetViewSettingsViewModel
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
        }
        .background(Color.Background.secondary)
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        PlainList {
            listContent
        }
        .environment(\.editMode, $editMode)
        
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
        
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.Button.active)
                    .environment(\.editMode, $editMode)
            }
            ToolbarItem(placement: .principal) {
                AnytypeText(Loc.settings, style: .uxTitle1Semibold, color: .Text.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation { editMode = .inactive }
                    model.showAddNewRelationView()
                }) {
                    Image(asset: .X32.plus).foregroundColor(.Button.active)
                }
            }
        }
    }
    
    private var listContent: some View {
        Group {
            VStack(spacing: 0) {
                settingsSection
                ListSectionHeaderView(title: Loc.relations)
            }
            relationsSection
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var settingsSection: some View {
        Group {
            switch model.contentViewType {
            case .collection(let type):
                if type == .gallery {
                    valueSetting(with: model.cardSizeSetting)
                    toggleSettings(with: model.iconSetting)
                    valueSetting(with: model.imagePreviewSetting)
                    toggleSettings(with: model.coverFitSetting)
                } else {
                    toggleSettings(with: model.iconSetting)
                }
            case .kanban:
                valueSetting(with: model.groupBySetting)
                toggleSettings(with: model.groupBackgroundColorsSetting)
                toggleSettings(with: model.iconSetting)
            case .table:
                toggleSettings(with: model.iconSetting)
            }
        }
    }
    
    private func valueSetting(with model: EditorSetViewSettingsValueItem) -> some View {
        Button {
            model.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(model.title, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                AnytypeText(model.value, style: .uxBodyRegular, color: .Text.secondary)
                Spacer.fixedWidth(11)
                Image(asset: .arrowForward)
                    .renderingMode(.template)
                    .foregroundColor(.Text.secondary)
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
    
    private var relationsSection: some View {
        ForEach(model.relations) { relation in
            relationRow(relation)
                .divider()
                .deleteDisabled(relation.isSystem)
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
                .foregroundColor(.Button.active)
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

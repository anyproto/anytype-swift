import SwiftUI
import AnytypeCore

struct SetRelationsView: View {
    @StateObject var model: SetRelationsViewModel
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
            relationsSection
                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
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
                AnytypeText(Loc.relations, style: .uxTitle1Semibold, color: .Text.primary)
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
    
    private var relationsSection: some View {
        ForEach(model.relations) { relation in
            relationRow(relation)
                .divider()
                .deleteDisabled(!relation.canBeRemovedFromObject)
        }
        .onDelete { indexes in
            model.deleteRelations(indexes: indexes)
        }
        .onMove { from, to in
            model.moveRelation(from: from, to: to)
        }
    }
    
    private func relationRow(_ relation: SetViewSettingsRelation) -> some View {
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

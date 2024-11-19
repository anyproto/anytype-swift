import SwiftUI
import Services

struct TypeFieldsView: View {
    
    @StateObject private var model: TypeFieldsViewModel
    
    init(data: EditorTypeObject, output: (any RelationsListModuleOutput)?) {
        _model = StateObject(wrappedValue: TypeFieldsViewModel(data: data, output: output))
    }
    
    init(document: some BaseDocumentProtocol, output: (any RelationsListModuleOutput)?) {
        _model = StateObject(wrappedValue: TypeFieldsViewModel(document: document, output: output))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            banner
            fieldsList
        }
    }
    
    private var navigationBar: some View {
        HStack {
            if model.canEditRelationsList {
                cancelButton
            }
            
            Spacer()
            AnytypeText(Loc.relations, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
            
            if model.canEditRelationsList {
                saveButton
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var cancelButton: some View {
        StandardButton(Loc.cancel, style: .borderlessSmall) {
            // TBD;
        }.disabled(true)
    }
    
    private var saveButton: some View {
        StandardButton(Loc.save, style: .borderlessSmall) {
            // TBD;
        }.disabled(true)
    }
    
    private var banner: some View {
        HStack(spacing: 0) {
            Spacer()
            AnytypeText(Loc.ObjectType.editingType, style: .previewTitle2Regular)
            Spacer.fixedWidth(8)
            IconView(icon: model.document.details?.objectIconImage).frame(width: 18, height: 18)
            Spacer.fixedWidth(5)
            AnytypeText(model.document.details?.title ?? "", style: .previewTitle2Medium)
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.Shape.tertiary)
    }
    
    private var fieldsList: some View {
        PlainList {
            relationsSection
                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        .environment(\.editMode, $model.editMode)
        
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var relationsSection: some View {
        ForEach(model.relations) { data in
            Section {
                relationRow(data)
                    .divider()
                    .deleteDisabled(!data.relation.canBeRemovedFromObject)
            } header: {
                // hacky way to enable dnd between sections: All views should be within single ForEach loop
                if data.relationIndex == 0 {
                    ListSectionHeaderView(title: data.sectionTitle)
                }
            }
        }
        .onDelete { indexes in
            // TBD;
        }
//        .onMove { from, to in
            // TBD;
//        }
    }
    
    private func relationRow(_ data: TypeFieldsRelationsData) -> some View {
        HStack(spacing: 0) {
            Image(asset: data.relation.iconAsset)
                .foregroundColor(.Control.active)
            Spacer.fixedWidth(10)
            AnytypeText(data.relation.name, style: .uxBodyRegular)
            Spacer()
        }
        .frame(height: 52)
    }
}

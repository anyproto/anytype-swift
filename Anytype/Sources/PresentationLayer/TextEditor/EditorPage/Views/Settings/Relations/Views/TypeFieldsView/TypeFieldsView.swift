import SwiftUI
import Services

struct TypeFieldsView: View {
    
    @StateObject private var model: TypeFieldsViewModel
    
    init(data: EditorTypeObject) {
        _model = StateObject(wrappedValue: TypeFieldsViewModel(data: data))
    }
    
    init(document: some BaseDocumentProtocol) {
        _model = StateObject(wrappedValue: TypeFieldsViewModel(document: document))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
        
            .sheet(item: $model.relationsSearchData) { data in
                RelationsSearchCoordinatorView(data: data)
            }
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
        ForEach(model.relationRows) { row in
            switch row {
            case .header(let header):
                headerRow(header)
                    .deleteDisabled(true)
                    .moveDisabled(true)
            case .relation(let relation):
                relationRow(relation)
                    .divider()
            case .emptyRow:
                Rectangle().foregroundStyle(Color.Background.secondary).frame(height: 52)
                    .deleteDisabled(true)
                    .moveDisabled(true)
            }
        }
        .onDelete { indexes in
            model.onDeleteRelations(indexes)
        }
        .onMove { from, to in
            model.onMove(from: from, to: to)
        }
    }
    
    private func headerRow(_ data: TypeFieldsSectionRow) -> some View {
        ListSectionHeaderView(title: data.title, increasedTopPadding: false) {
            Button(action: {
                model.onAddRelationTap(section: data)
            }, label: {
                IconView(asset: .X24.plus).frame(width: 24, height: 24)
            })
        }
    }
    
    private func relationRow(_ data: TypeFieldsRelationRow) -> some View {
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

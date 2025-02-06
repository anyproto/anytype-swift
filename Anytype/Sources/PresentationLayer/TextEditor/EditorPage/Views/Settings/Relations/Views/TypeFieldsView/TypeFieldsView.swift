import SwiftUI
import Services

struct TypeFieldsView: View {
    
    @StateObject private var model: TypeFieldsViewModel
    
    @State private var draggedRow: TypeFieldsRow?
    
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
            .sheet(item: $model.relationData) {
                RelationInfoCoordinatorView(data: $0, output: nil)
            }
            .anytypeSheet(isPresented: $model.showConflictingInfo) {
                ObjectFieldsBottomAlert()
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
            Spacer()
            AnytypeText(Loc.fields, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
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
        .background(Color.Shape.transperentSecondary)
    }
    
    private var fieldsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                relationsSection
                
                if model.conflictRelations.isNotEmpty {
                    localFieldsSection
                        .padding(.horizontal, 20)
                }
            }
        }
        
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var relationsSection: some View {
        ForEach(model.relationRows) { row in
            Group {
                switch row {
                case .header(let header):
                    headerRow(header).padding(.horizontal, 20)
                case .relation(let relation):
                    relationRow(relation)
                        .divider()
                case .emptyRow:
                    Rectangle().foregroundStyle(Color.Background.secondary).frame(height: 52)
                }
            }
            .onDrop(of: [.text], delegate: TypeFieldsDropDelegate(
                destinationRow: row,
                document: model.document,
                draggedRow: $draggedRow,
                allRows: $model.relationRows)
            )
        }
    }
    
    private func headerRow(_ data: TypeFieldsSectionRow) -> some View {
        ListSectionHeaderView(title: data.title, increasedTopPadding: true) {
            if model.canEditRelationsList {
                Button(action: {
                    model.onAddRelationTap(section: data)
                }, label: {
                    IconView(asset: .X24.plus).frame(width: 24, height: 24)
                })
            }
        }
    }
    
    private func relationRow(_ data: TypeFieldsRelationRow) -> some View {
        HStack(spacing: 0) {
            Button {
                model.onRelationTap(data)
            } label: {
                Image(asset: data.relation.iconAsset)
                    .foregroundColor(.Control.active)
                Spacer.fixedWidth(10)
                AnytypeText(data.relation.name, style: .uxBodyRegular)
                
                Spacer()
            }.disabled(!model.canEditRelationsList || !data.relation.isEditable)
            
            if model.canEditRelationsList && data.canDrag {
                MoveIndicator()
            }
        }
        .frame(height: 52)
        .contentShape([.dragPreview], RoundedRectangle(cornerRadius: 4, style: .continuous))
        
        .padding(.horizontal, 20)
        .contextMenu {
            if model.canEditRelationsList && data.relation.isEditable {
                Button(Loc.delete, role: .destructive) {
                    model.onDeleteRelation(data)
                }
            }
        }
        
        .if(model.canEditRelationsList && data.canDrag) {
            $0.onDrag {
                draggedRow = .relation(data)
                return NSItemProvider()
            } preview: {
                EmptyView()
            }
        }
    }
    
    // MARK: - Local fields
    private var localFieldsSection: some View {
        VStack(spacing: 0) {
            Button(action: {
                model.showConflictingInfo.toggle()
            }, label: {
                ListSectionHeaderView(title: Loc.Fields.local, increasedTopPadding: true) {
                    Image(systemName: "questionmark.circle.fill").foregroundStyle(Color.Control.active)
                        .frame(width: 18, height: 18)
                }
            })
            
            ForEach(model.conflictRelations) {
                localFieldRow($0)
            }
        }
    }
    
    private func localFieldRow(_ data: RelationDetails) -> some View {
        HStack(spacing: 0) {
            Menu {
                Button(Loc.Fields.addToType) { model.onAddConflictRelation(data) }
            } label: {
                Image(asset: data.format.iconAsset)
                    .foregroundColor(.Control.active)
                Spacer.fixedWidth(10)
                AnytypeText(data.name, style: .uxBodyRegular)
                
                Spacer()
        
                MoreIndicator()
            }
        }
        .frame(height: 52)
    }
}

import SwiftUI
import Services
import AnytypeCore


struct TypePropertiesView: View {
    
    @StateObject private var model: TypePropertiesViewModel
    
    @State private var draggedRow: TypePropertiesRow?
    
    init(data: EditorTypeObject) {
        _model = StateObject(wrappedValue: TypePropertiesViewModel(data: data))
    }
    
    init(document: some BaseDocumentProtocol) {
        _model = StateObject(wrappedValue: TypePropertiesViewModel(document: document))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
            .sheet(item: $model.relationsSearchData) { data in
                RelationCreationView(data: data)
            }
            .sheet(item: $model.propertyData) {
                PropertyInfoCoordinatorView(data: $0, output: nil)
            }
            .anytypeSheet(isPresented: $model.showConflictingInfo) {
                ObjectPropertiesBottomAlert()
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
            AnytypeText(Loc.ObjectType.editingType, style: .caption1Medium)
            Spacer.fixedWidth(8)
            IconView(icon: model.document.details?.objectIconImage).frame(width: 18, height: 18)
            Spacer.fixedWidth(5)
            AnytypeText(model.document.details?.title ?? "", style: .caption1Medium)
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.Shape.transperentSecondary)
    }
    
    private var fieldsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                propertiesSection
                
                if model.conflictRelations.isNotEmpty {
                    localFieldsSection
                        .padding(.horizontal, 20)
                }
            }
        }
        
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var propertiesSection: some View {
        ForEach(model.relationRows) { row in
            Group {
                switch row {
                case .header(let header):
                    headerRow(header).padding(.horizontal, 20)
                case .relation(let relation):
                    propertyRow(relation)
                        .divider()
                case .emptyRow:
                    Rectangle().foregroundStyle(Color.clear).fixTappableArea().frame(height: 52)
                }
            }
            .onDrop(of: [.text], delegate: TypePropertiesDropDelegate(
                destinationRow: row,
                document: model.document,
                draggedRow: $draggedRow,
                allRows: $model.relationRows)
            )
        }
    }
    
    private func headerRow(_ data: TypePropertiesSectionRow) -> some View {
        ListSectionHeaderView(title: data.title, increasedTopPadding: true) {
            if model.canEditPropertiesList && data.canCreateRelations {
                Button(action: {
                    model.onAddRelationTap(section: data)
                }, label: {
                    IconView(asset: .X24.plus).frame(width: 24, height: 24)
                })
            }
        }
    }
    
    private func propertyRow(_ data: TypePropertiesRelationRow) -> some View {
        HStack(spacing: 0) {
            Button {
                model.onRelationTap(data)
            } label: {
                Image(asset: data.relation.iconAsset)
                    .foregroundColor(.Control.active)
                Spacer.fixedWidth(10)
                AnytypeText(data.relation.name, style: .uxBodyRegular)
                
                Spacer()
            }.disabled(!model.canEditPropertiesList || !data.relation.isEditable)
            
            if model.canEditPropertiesList && data.canDrag {
                MoveIndicator()
            }
        }
        .frame(height: 52)
        .contentShape([.dragPreview], RoundedRectangle(cornerRadius: 4, style: .continuous))
        
        .padding(.horizontal, 20)
        .contextMenu {
            if model.canEditPropertiesList {
                Button(Loc.remove, role: .destructive) {
                    model.onRelationRemove(data)
                }
            }
        }
        
        .if(model.canEditPropertiesList && data.canDrag) {
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
                model.onConflictingInfoTap()
            }, label: {
                ListSectionHeaderView(title: Loc.Fields.foundInObjects, increasedTopPadding: true) {
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

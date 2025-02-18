import SwiftUI
import Services

struct ObjectFieldsView: View {
    
    @StateObject private var model: ObjectFieldsViewModel
    
    init(document: some BaseDocumentProtocol, output: (any RelationsListModuleOutput)?) {
        _model = StateObject(wrappedValue: ObjectFieldsViewModel(document: document, output: output))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
            .anytypeSheet(isPresented: $model.showConflictingInfo) {
                ObjectFieldsBottomAlert()
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            relationsList
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
        .overlay(alignment: .trailing) {
            if model.typeId.isNotNil {
                editButton
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var editButton: some View {
        Button {
            withAnimation(.fastSpring) {
                model.onEditTap()
            }
        } label: {
            IconView(asset: .X24.settings).frame(width: 24, height: 24)
        }
    }
    
    private var relationsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(model.sections) { section in
                    Section {
                        ForEach(section.relations) {
                            row(with: $0, section: section)
                        }
                    } header: {
                        sectionHeader(section: section)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(section: RelationsSection) -> some View {
        Group {
            if section.isMissingFields {
                Button {
                    model.showConflictingInfo.toggle()
                } label: {
                    ListSectionHeaderView(title: section.title) {
                        Image(systemName: "questionmark.circle.fill").foregroundStyle(Color.Control.active)
                            .frame(width: 18, height: 18)
                    }
                }
            } else {
                ListSectionHeaderView(title: section.title)
            }
        }
    }
    
    private func row(with relation: Relation, section: RelationsSection) -> some View {
        HStack {
            rowWithoutActions(with: relation, addedToObject: section.addedToObject)
            if section.isMissingFields {
                Menu {
                    Button(Loc.Fields.addToType) { model.addRelationToType(relation) }
                    Button(Loc.Fields.removeFromObject, role: .destructive) { model.removeRelation(relation) }
                } label: {
                    MoreIndicator()
                }
            }
        }
        .divider()
    }
    
    private func rowWithoutActions(with relation: Relation, addedToObject: Bool) -> some View {
        RelationsListRowView(
            editingMode: .constant(false),
            starButtonAvailable: false,
            showLocks: false,
            addedToObject: addedToObject,
            relation: relation
        ) {
            model.removeRelation($0)
        } onStarTap: {
            model.changeRelationFeaturedState(relation: $0, addedToObject: addedToObject)
        } onEditTap: {
            model.handleTapOnRelation($0)
        }
    }
}

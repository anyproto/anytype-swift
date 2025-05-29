import SwiftUI
import Services
import AnytypeCore


struct ObjectPropertiesView: View {
    
    @StateObject private var model: ObjectPropertiesViewModel
    
    init(document: some BaseDocumentProtocol, output: (any PropertiesListModuleOutput)?) {
        _model = StateObject(wrappedValue: ObjectPropertiesViewModel(document: document, output: output))
    }
    
    var body: some View {
        content
            .task { await model.setupSubscriptions() }
            .anytypeSheet(isPresented: $model.showConflictingInfo) {
                ObjectPropertiesBottomAlert()
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
                    model.onConflictingInfoTap()
                } label: {
                    ListSectionHeaderView(title: section.title) {
                        Image(systemName: "questionmark.circle.fill").foregroundStyle(Color.Control.active)
                            .frame(width: 18, height: 18)
                    }
                }
            } else {
                EmptyView()
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
        // Deprecated design
        // TODO: Support new rows without stars and deletion
        // https://www.figma.com/design/16UsBI2PLwydmAC4wJfyu8/%5BM%5D-All-content-%26-Type?node-id=19264-38639&t=fgXeqZbpBgUNrB2C-4
        PropertiesListRowView(
            editingMode: .constant(false),
            starButtonAvailable: false,
            showLocks: false,
            addedToObject: addedToObject,
            relation: relation
        ) { _ in
            anytypeAssertionFailure("Deprecated row delete call")
        } onStarTap: { _ in
            anytypeAssertionFailure("Deprecated onStarTap call")
        } onEditTap: {
            model.handleTapOnRelation($0)
        }
    }
}

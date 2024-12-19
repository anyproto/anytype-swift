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
            AnytypeText(Loc.relations, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
            
            if model.typeId.isNotNil {
                editButton
            }
        }
        .frame(height: 48)
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
                            row(with: $0, addedToObject: section.addedToObject)
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
            if let action = section.action {
                Button {
                    action.action()
                } label: {
                    ListSectionHeaderView(title: section.title, titleColor: action.color) {
                        Image(systemName: action.iconSystemName).foregroundStyle(action.color)
                            .frame(width: 18, height: 18)
                    }
                }
            } else {
                ListSectionHeaderView(title: section.title)
            }
        }
    }
    
    private func row(with relation: Relation, addedToObject: Bool) -> some View {
        RelationsListRowView(
            editingMode: .constant(false),
            starButtonAvailable: false,
            showLocks: false,
            addedToObject: addedToObject,
            relation: relation
        ) {
            model.removeRelation(relation: $0)
        } onStarTap: {
            model.changeRelationFeaturedState(relation: $0, addedToObject: addedToObject)
        } onEditTap: {
            model.handleTapOnRelation(relation: $0)
        }
    }
    
}

import SwiftUI
import Services

struct ObjectFieldsView: View {
    
    @StateObject private var viewModel: ObjectFieldsViewModel
    
    init(document: some BaseDocumentProtocol, output: (any RelationsListModuleOutput)?) {
        _viewModel = StateObject(wrappedValue: ObjectFieldsViewModel(document: document, output: output))
    }
    
    var body: some View {
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
            
            if !viewModel.navigationBarButtonsDisabled {
                editButton
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var editButton: some View {
        Button {
            withAnimation(.fastSpring) {
                // TBD;
            }
        } label: {
            IconView(asset: .X24.settings).frame(width: 24, height: 24)
        }
    }
    
    private var relationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        Section(header: sectionHeader(title: section.title)) {
                            ForEach(section.relations) {
                                row(with: $0, addedToObject: section.addedToObject)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        Group {
            if title.isNotEmpty {
                ListSectionHeaderView(title: title)
            } else {
                EmptyView()
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
            viewModel.removeRelation(relation: $0)
        } onStarTap: {
            viewModel.changeRelationFeaturedState(relation: $0, addedToObject: addedToObject)
        } onEditTap: {
            viewModel.handleTapOnRelation(relation: $0)
        }
    }
    
}

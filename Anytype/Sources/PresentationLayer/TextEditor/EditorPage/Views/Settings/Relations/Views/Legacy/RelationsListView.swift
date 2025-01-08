import SwiftUI
import Services

struct RelationsListView: View {
    
    @StateObject private var viewModel: RelationsListViewModel
    @State private var editingMode = false
    
    init(document: some BaseDocumentProtocol, output: (any RelationsListModuleOutput)?) {
        _viewModel = StateObject(wrappedValue: RelationsListViewModel(document: document, output: output))
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
            if !viewModel.navigationBarButtonsDisabled {
                editButton
            }
            
            Spacer()
            AnytypeText(Loc.relations, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer()
            
            if !viewModel.navigationBarButtonsDisabled {
                createNewRelationButton
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
    }
    
    private var editButton: some View {
        Button {
            withAnimation(.fastSpring) {
                editingMode.toggle()
            }
        } label: {
            AnytypeText(
                editingMode ? Loc.done : Loc.edit,
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.secondary)
        }
    }
    
    private var createNewRelationButton: some View {
        Button {
            viewModel.showAddRelationInfoView()
        } label: {
            Image(asset: .X32.plus)
                .foregroundColor(.Control.active)
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
        ListSectionHeaderView(title: title)
    }
    
    private func row(with relation: Relation, addedToObject: Bool) -> some View {
        RelationsListRowView(
            editingMode: $editingMode,
            starButtonAvailable: !viewModel.navigationBarButtonsDisabled,
            showLocks: true,
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

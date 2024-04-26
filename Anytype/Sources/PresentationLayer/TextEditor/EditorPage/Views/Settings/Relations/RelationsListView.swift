import SwiftUI
import Services

struct RelationsListView: View {
    
    @ObservedObject var viewModel: RelationsListViewModel
    @State private var editingMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            relationsList
        }
    }
    
    private var navigationBar: some View {
        HStack {
            editButton
            Spacer()
            AnytypeText(Loc.relations, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer()
            createNewRelationButton
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
                style: .uxBodyRegular,
                color: viewModel.navigationBarButtonsDisabled ? .Button.inactive : .Text.secondary
            )
        }
        .disabled(viewModel.navigationBarButtonsDisabled)
    }
    
    private var createNewRelationButton: some View {
        Button {
            viewModel.showAddNewRelationView()
        } label: {
            Image(asset: .X32.plus)
                .foregroundColor(viewModel.navigationBarButtonsDisabled ? .Button.inactive : .Button.active)
        }
        .disabled(viewModel.navigationBarButtonsDisabled)
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

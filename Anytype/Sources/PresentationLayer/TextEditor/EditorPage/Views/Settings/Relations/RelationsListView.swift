import SwiftUI
import BlocksModels

struct RelationsListView: View {
    
    @ObservedObject var viewModel: RelationsListViewModel
    @State private var editingMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBar
            relationsList
        }
    }
    
    private var navigationBar: some View {
        HStack {
            editButton
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
                color: viewModel.navigationBarButtonsDisabled ? .buttonInactive : .textSecondary
            )
        }
        .disabled(viewModel.navigationBarButtonsDisabled)
    }
    
    private var createNewRelationButton: some View {
        Button {
            viewModel.showAddNewRelationView()
        } label: {
            Image(asset: .relationNew)
                .if(viewModel.navigationBarButtonsDisabled) {
                    $0.renderingMode(.template)
                        .foregroundColor(.buttonInactive)
                }
                .frame(width: 24, height: 24)
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
                                row(with: $0)
                            }
                        }
                        
                        Spacer().frame(height: 20)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        AnytypeText(title, style: .uxTitle1Semibold, color: .textPrimary)
            .frame(height: 48)
    }
    
    private func row(with relation: Relation) -> some View {
        RelationsListRowView(editingMode: $editingMode, starButtonAvailable: !viewModel.navigationBarButtonsDisabled, relation: relation) {
            viewModel.removeRelation(id: $0)
        } onStarTap: {
            viewModel.changeRelationFeaturedState(relationKey: $0)
        } onEditTap: {
            viewModel.handleTapOnRelation(relationKey: $0)
        }
    }
    
}

import SwiftUI

struct StatusRelationEditingView: View {
    
    @ObservedObject var viewModel: StatusRelationEditingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            statusesList
            Spacer.fixedHeight(20)
        }
    }
    
    private var statusesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.statusSections) { section in
                    VStack(alignment: .leading, spacing: 0) {
                        Section(header: sectionHeader(title: section.title)) {
                            ForEach(section.statuses) { statusRow($0) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            .padding(.top, 26)
            .padding(.bottom, 8)
            .modifier(DividerModifier(spacing: 0, alignment: .leading))
    }
    
    private func statusRow(_ status: RelationValue.Status) -> some View {
        StatusRelationRowView(
            status: status,
            isSelected: status == viewModel.selectedStatus
        ) {
            if viewModel.selectedStatus == status {
                viewModel.selectedStatus = nil
            } else {
                viewModel.selectedStatus = status
            }
        }
    }
}

struct StatusRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationEditingView(
            viewModel: StatusRelationEditingViewModel(
                relationKey: "",
                relationOptions: [],
                selectedStatus: nil,
                detailsService: DetailsService(objectId: "")
            )
        )
    }
}

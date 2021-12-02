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
                            ForEach(section.statuses) { status in
                                StatusRelationRowView(
                                    status: status,
                                    isSelected: status == viewModel.selectedStatus
                                )
                            }
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

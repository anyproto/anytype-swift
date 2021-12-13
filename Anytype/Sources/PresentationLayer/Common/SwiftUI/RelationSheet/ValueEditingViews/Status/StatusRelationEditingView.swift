import SwiftUI

struct StatusRelationEditingView: View {
    
    @ObservedObject var viewModel: StatusRelationEditingViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false)
            statusesList
            Spacer.fixedHeight(20)
        }
        .modifier(RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.relationName, dismissCallback: viewModel.onDismiss))
        .onChange(of: searchText) { viewModel.filterStatusSections(text: $0) }
    }
    
    private var statusesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.statusSections.isEmpty {
                    createStatusButton
                }
                
                ForEach(viewModel.statusSections) { section in
                    Section(header: sectionHeader(title: section.title)) {
                        ForEach(section.statuses) { statusRow($0) }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var createStatusButton: some View {
        Group {
            Button {
                viewModel.addOption(text: searchText)
            } label: {
                HStack(spacing: 8) {
                    Image.Relations.createOption.frame(width: 24, height: 24)
                    AnytypeText("\("Create option".localized) \"\(searchText)\"", style: .uxBodyRegular, color: .textSecondary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.vertical, 14)
            }
        }
        .modifier(DividerModifier(spacing: 0))
    }
    
    private func sectionHeader(title: String) -> some View {
        AnytypeText(title, style: .caption1Regular, color: .textSecondary)
            .padding(.top, 26)
            .padding(.bottom, 8)
            .modifier(DividerModifier(spacing: 0, alignment: .leading))
    }
    
    private func statusRow(_ status: NewRelation.Status.Option) -> some View {
        StatusRelationRowView(
            status: status,
            isSelected: status == viewModel.selectedStatus
        ) {
            if viewModel.selectedStatus == status {
                viewModel.selectedStatus = nil
            } else {
                viewModel.selectedStatus = status
            }
            
            viewModel.saveValue()
        }
    }
}

struct StatusRelationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationEditingView(
            viewModel: StatusRelationEditingViewModel(
                relationKey: "",
                relationName: "",
                relationOptions: [],
                selectedStatus: nil,
                detailsService: DetailsService(objectId: ""),
                relationsService: RelationsService(objectId: "")
            )
        )
    }
}

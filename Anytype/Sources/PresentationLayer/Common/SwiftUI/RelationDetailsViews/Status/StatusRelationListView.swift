import SwiftUI

struct StatusRelationListView: View {
    
    @StateObject var viewModel: StatusRelationListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        RelationListContainerView(
            title: viewModel.configuration.title,
            isEmpty: viewModel.isEmpty,
            listContent: {
                ForEach(viewModel.statuses) { status in
                    statusRow(with: status)
                }
            },
            onCreate: { title in
                viewModel.create(with: title)
            },
            onClear: {
                viewModel.clear()
            },
            onSearchTextChange: { text in
                viewModel.searchTextChanged(text)
            }
        )
        .onAppear {
            viewModel.searchTextChanged()
        }
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
    }
    
    private func statusRow(with status: Relation.Status.Option) -> some View {
        Button {
            viewModel.statusSelected(status.id)
        } label: {
            HStack {
                AnytypeText(status.text, style: .relation1Regular, color: status.color.suColor)
                Spacer()
                if status.id == viewModel.selectedStatus?.id {
                    Image(asset: .relationCheckboxChecked)
                }
            }
        }
        .frame(height: 52)
        .newDivider()
        .padding(.horizontal, 20)
    }
}

struct StatusRelationListView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationListView(
            viewModel: StatusRelationListViewModel(
                configuration: RelationModuleConfiguration(
                    title: "Status",
                    isEditable: true,
                    relationKey: "",
                    spaceId: "",
                    analyticsType: .block
                ),
                selectedStatus: nil,
                relationsService: DI.preview.serviceLocator.relationService(objectId: ""),
                searchService: DI.preview.serviceLocator.searchService()
            )
        )
    }
}

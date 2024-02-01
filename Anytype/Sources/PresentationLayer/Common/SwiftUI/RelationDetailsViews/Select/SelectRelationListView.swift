import SwiftUI

struct SelectRelationListView: View {
    
    @StateObject var viewModel: SelectRelationListViewModel
    
    var body: some View {
        RelationListContainerView(
            searchText: $viewModel.searchText,
            title: viewModel.configuration.title,
            isEditable: viewModel.configuration.isEditable,
            isEmpty: viewModel.isEmpty,
            hideClear: viewModel.selectedOptionId.isNil,
            listContent: {
                ForEach(viewModel.options) { option in
                    optionRow(with: option)
                }
                .onDelete {
                    viewModel.onOptionDelete(with: $0)
                }
            },
            onCreate: { title in
                viewModel.onCreate(with: title)
            },
            onClear: {
                viewModel.onClear()
            },
            onSearchTextChange: { text in
                viewModel.searchTextChanged(text)
            }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private func optionRow(with option: SelectRelationOption) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                AnytypeText(option.text, style: .relation1Regular, color: option.color)
                Spacer()
                if option.id == viewModel.selectedOptionId, viewModel.configuration.isEditable {
                    Image(asset: .relationCheckboxChecked)
                }
            }
        }
        .frame(height: 52)
        .newDivider()
        .padding(.horizontal, 20)
        .contextMenu {
            Button(Loc.edit) {
                viewModel.onOptionEdit(option)
            }
            Button(Loc.duplicate) {
                viewModel.onOptionDuplicate(option)
            }
            Button(Loc.delete, role: .destructive) {
                viewModel.onOptionDelete(option)
            }
        }
    }
}

#Preview("Status list") {
    SelectRelationListView(
        viewModel: SelectRelationListViewModel(
            configuration: RelationModuleConfiguration(
                title: "Status",
                isEditable: true,
                relationKey: "",
                spaceId: "",
                analyticsType: .block
            ),
            selectedOptionId: nil,
            output: nil,
            relationsService: DI.preview.serviceLocator.relationService(objectId: ""),
            searchService: DI.preview.serviceLocator.searchService()
        )
    )
}

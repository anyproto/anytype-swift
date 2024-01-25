import SwiftUI

struct SelectRelationListView: View {
    
    @StateObject var viewModel: SelectRelationListViewModel
    
    var body: some View {
        RelationListContainerView(
            title: viewModel.configuration.title, 
            isEditable: viewModel.configuration.isEditable,
            isEmpty: viewModel.isEmpty,
            listContent: {
                ForEach(viewModel.options) { option in
                    optionRow(with: option)
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
    }
    
    private func optionRow(with option: SelectRelationOption) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                AnytypeText(option.text, style: .relation1Regular, color: option.color)
                Spacer()
                if option == viewModel.selectedOption, viewModel.configuration.isEditable {
                    Image(asset: .relationCheckboxChecked)
                }
            }
        }
        .frame(height: 52)
        .newDivider()
        .padding(.horizontal, 20)
    }
}

struct SelectRelationListView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRelationListView(
            viewModel: SelectRelationListViewModel(
                configuration: RelationModuleConfiguration(
                    title: "Status",
                    isEditable: true,
                    relationKey: "",
                    spaceId: "",
                    analyticsType: .block
                ),
                selectedOption: nil, 
                output: nil,
                relationsService: DI.preview.serviceLocator.relationService(objectId: ""),
                searchService: DI.preview.serviceLocator.searchService()
            )
        )
    }
}

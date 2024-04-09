import SwiftUI

struct SelectRelationListView: View {
    
    @StateObject var viewModel: SelectRelationListViewModel
    
    init(data: SelectRelationListData, output: SelectRelationListModuleOutput?) {
        _viewModel = StateObject(wrappedValue: SelectRelationListViewModel(data: data, output: output))
    }
    
    var body: some View {
        RelationListContainerView(
            searchText: $viewModel.searchText,
            title: viewModel.configuration.title,
            isEditable: viewModel.configuration.isEditable,
            isEmpty: viewModel.isEmpty,
            isClearAvailable: viewModel.selectedOptionsIds.isNotEmpty,
            isCreateAvailable: true,
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
        .disabled(!viewModel.configuration.isEditable)
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private func optionRow(with option: SelectRelationOption) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                rowContent(with: option)
                
                Spacer()
                
                if viewModel.configuration.isEditable {
                    RelationListSelectionView(
                        selectionMode: viewModel.configuration.selectionMode,
                        selectedIndex: viewModel.selectedOptionsIds.firstIndex(of: option.id)
                    )
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
    
    @ViewBuilder
    private func rowContent(with option: SelectRelationOption) -> some View {
        switch viewModel.style {
        case .status:
            AnytypeText(option.text, style: .relation1Regular)
                .foregroundColor(option.color)
        case .tag:
            TagView(
                config: TagView.Config(
                    text: option.text,
                    textColor: option.color,
                    backgroundColor: option.color.veryLightColor(),
                    textFont: .relation1Regular,
                    guidlines: TagView.Guidlines(textPadding: 6, cornerRadius: 3, tagHeight: 20)
                )
            )
        }
    }
}

#Preview("Status list") {
    SelectRelationListView(
        data: SelectRelationListData(
            style: .status,
            configuration: RelationModuleConfiguration.default,
            relationSelectedOptionsModel: RelationSelectedOptionsModel(config: RelationModuleConfiguration.default, selectedOptionsIds: [])
        ),
        output: nil
    )
}

#Preview("Tag list") {
    SelectRelationListView(
        data: SelectRelationListData(
            style: .tag,
            configuration: RelationModuleConfiguration.default,
            relationSelectedOptionsModel: RelationSelectedOptionsModel(config: RelationModuleConfiguration.default, selectedOptionsIds: [])
        ),
        output: nil
    )
}

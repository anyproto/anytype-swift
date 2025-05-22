import SwiftUI

struct SelectPropertyListView: View {
    
    @StateObject var viewModel: SelectPropertyListViewModel
    
    init(data: SelectPropertyListData, output: (any SelectPropertyListModuleOutput)?) {
        _viewModel = StateObject(wrappedValue: SelectPropertyListViewModel(data: data, output: output))
    }
    
    var body: some View {
        PropertyListContainerView(
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
            }
        )
        .disabled(!viewModel.configuration.isEditable)
        .task(id: viewModel.searchText) {
            await viewModel.searchTextChanged()
        }
    }
    
    private func optionRow(with option: SelectPropertyOption) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                rowContent(with: option)
                
                Spacer()
                
                if viewModel.configuration.isEditable {
                    PropertyListSelectionView(
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
    private func rowContent(with option: SelectPropertyOption) -> some View {
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
    SelectPropertyListView(
        data: SelectPropertyListData(
            style: .status,
            configuration: PropertyModuleConfiguration.default,
            relationSelectedOptionsModel: PropertySelectedOptionsModel(config: PropertyModuleConfiguration.default, selectedOptionsIds: [])
        ),
        output: nil
    )
}

#Preview("Tag list") {
    SelectPropertyListView(
        data: SelectPropertyListData(
            style: .tag,
            configuration: PropertyModuleConfiguration.default,
            relationSelectedOptionsModel: PropertySelectedOptionsModel(config: PropertyModuleConfiguration.default, selectedOptionsIds: [])
        ),
        output: nil
    )
}

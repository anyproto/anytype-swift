import SwiftUI

struct SelectRelationListView: View {
    
    @StateObject var viewModel: SelectRelationListViewModel
    
    var body: some View {
        RelationListContainerView(
            searchText: $viewModel.searchText,
            title: viewModel.configuration.title,
            isEditable: viewModel.configuration.isEditable,
            isEmpty: viewModel.isEmpty,
            hideClear: viewModel.selectedOptionsIds.isEmpty,
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
                rowContent(with: option)
                
                Spacer()
                
                if viewModel.configuration.isEditable {
                    rowSelection(with: option)
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
            AnytypeText(option.text, style: .relation1Regular, color: option.color)
        case .tag:
            TagOptionView(
                text: option.text,
                textColor: option.color,
                backgroundColor: option.color.veryLightColor()
            )
        }
    }
    
    @ViewBuilder
    private func rowSelection(with option: SelectRelationOption) -> some View {
        switch viewModel.relationSelectedOptionsModel.selectionMode {
        case .single:
            if viewModel.selectedOptionsIds.contains(option.id) {
                Image(asset: .relationCheckboxChecked)
            }
        case .multi:
            if let index = viewModel.selectedOptionsIds.firstIndex(of: option.id) {
                SelectionIndicatorView(model: .selected(index: index + 1, color: Color.System.sky))
            } else {
                SelectionIndicatorView(model: .notSelected)
            }
        }
    }
}

#Preview("Status list") {
    SelectRelationListView(
        viewModel: SelectRelationListViewModel(
            style: .status,
            configuration: RelationModuleConfiguration(
                title: "Status",
                isEditable: true,
                relationKey: "",
                spaceId: "",
                analyticsType: .block
            ), 
            relationSelectedOptionsModel: RelationSelectedOptionsModel(
                selectionMode: .single,
                selectedOptionsIds: [],
                relationKey: "",
                analyticsType: .block,
                relationsService: DI.preview.serviceLocator.relationService(objectId: "")
            ),
            searchService: DI.preview.serviceLocator.searchService(),
            output: nil
        )
    )
}

#Preview("Tag list") {
    SelectRelationListView(
        viewModel: SelectRelationListViewModel(
            style: .tag,
            configuration: RelationModuleConfiguration(
                title: "Tag",
                isEditable: true,
                relationKey: "",
                spaceId: "",
                analyticsType: .block
            ),
            relationSelectedOptionsModel: RelationSelectedOptionsModel(
                selectionMode: .multi,
                selectedOptionsIds: [],
                relationKey: "",
                analyticsType: .block,
                relationsService: DI.preview.serviceLocator.relationService(objectId: "")
            ),
            searchService: DI.preview.serviceLocator.searchService(),
            output: nil
        )
    )
}

import SwiftUI
import WrappingHStack

struct ObjectRelationListView: View {
    
    @StateObject var viewModel: ObjectRelationListViewModel
    
    var body: some View {
        RelationListContainerView(
            searchText: $viewModel.searchText,
            title: viewModel.configuration.title,
            isEditable: viewModel.configuration.isEditable,
            isEmpty: viewModel.isEmpty,
            isClearAvailable: viewModel.selectedOptionsIds.isNotEmpty,
            isCreateAvailable: false,
            listContent: {
                listContent
            },
            onCreate: { _ in },
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
    
    private var listContent: some View {
        Group {
            header
            ForEach(viewModel.options) { option in
                optionRow(with: option)
            }
            .onDelete {
                viewModel.onOptionDelete(with: $0)
            }
        }
    }
    
    @ViewBuilder
    private var header: some View {
        if let items = viewModel.objectRelationTypeItems() {
            WrappingHStack(items, spacing: .constant(5), lineSpacing: 0) { item in
                AnytypeText(
                    item.name,
                    style: item.isSelected ? .caption1Medium : .caption1Regular,
                    color: .Text.secondary
                )
            }
            .padding(.top, 26)
            .padding(.bottom, 8)
            .newDivider()
            .padding(.horizontal, 20)
        }
    }
    
    private func optionRow(with option: Relation.Object.Option) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                RelationObjectsRowView(
                    object: option,
                    action: {
                        viewModel.optionSelected(option.id)
                    }
                )
                
                Spacer()
                
                if viewModel.configuration.isEditable {
                    rowSelection(with: option.id)
                }
            }
        }
        .frame(height: 72)
        .newDivider()
        .padding(.horizontal, 20)
        .contextMenu {
            Button(Loc.openObject) {
                viewModel.onObjectOpen(option)
            }
            Button(Loc.duplicate) {
                viewModel.onObjectDuplicate(option)
            }
            Button(Loc.delete, role: .destructive) {
                viewModel.onOptionDelete(option)
            }
        }
    }
    
    @ViewBuilder
    private func rowSelection(with optionId: String) -> some View {
        switch viewModel.configuration.selectionMode {
        case .single:
            if viewModel.selectedOptionsIds.contains(optionId) {
                Image(asset: .relationCheckboxChecked)
            }
        case .multi:
            if let index = viewModel.selectedOptionsIds.firstIndex(of: optionId) {
                SelectionIndicatorView(model: .selected(index: index + 1, color: Color.System.sky))
            } else {
                SelectionIndicatorView(model: .notSelected)
            }
        }
    }
}

#Preview("Object") {
    SelectRelationListView(
        viewModel: SelectRelationListViewModel(
            style: .status,
            configuration: RelationModuleConfiguration(
                title: "Object",
                isEditable: true,
                relationKey: "",
                spaceId: "",
                selectionMode: .multi,
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

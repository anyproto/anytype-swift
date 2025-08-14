import SwiftUI
import WrappingHStack

struct ObjectPropertyListView: View {
    
    @StateObject var viewModel: ObjectPropertyListViewModel
    
    init(data: ObjectPropertyListData, output: (any ObjectPropertyListModuleOutput)?) {
        _viewModel = StateObject(wrappedValue: ObjectPropertyListViewModel(data: data, output: output))
    }
    
    var body: some View {
        PropertyListContainerView(
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
            }
        )
        .task(id: viewModel.searchText) {
            await viewModel.searchTextChanged()
        }
    }
    
    private var listContent: some View {
        Group {
            header
            ForEach(viewModel.options) { option in
                optionRow(with: option)
                    .deleteDisabled(option.disableDeletion)
            }
            .if(viewModel.configuration.isEditable) {
                $0.onDelete {
                    viewModel.onOptionDelete(with: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    private var header: some View {
        if viewModel.configuration.isEditable, let items = viewModel.objectRelationTypeItems() {
            WrappingHStack(alignment: .leading, horizontalSpacing: 6, verticalSpacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    AnytypeText(
                        items[index].name,
                        style: items[index].isSelected ? .caption1Medium : .caption1Regular
                    )
                    .foregroundColor(.Text.secondary)
                }
            }
            .padding(.top, 26)
            .padding(.bottom, 8)
            .newDivider()
            .padding(.horizontal, 20)
        }
    }
    
    private func optionRow(with option: ObjectPropertyOption) -> some View {
        Button {
            viewModel.optionSelected(option)
        } label: {
            HStack {
                ObjectPropertyOptionView(option: option)
                
                Spacer()
                
                if viewModel.configuration.isEditable {
                    PropertyListSelectionView(
                        selectionMode: viewModel.configuration.selectionMode,
                        selectedIndex: viewModel.selectedOptionsIds.firstIndex(of: option.id)
                    )
                }
            }
        }
        .frame(height: 72)
        .newDivider()
        .padding(.horizontal, 20)
        .if(viewModel.configuration.isEditable) {
            $0.contextMenu {
                Button(Loc.openObject) {
                    viewModel.onOpenAsObject(option)
                }
                
                if !option.disableDuplication {
                    Button(Loc.duplicate) {
                        viewModel.onObjectDuplicate(option)
                    }
                }
                
                if !option.disableDeletion {
                    Button(Loc.delete, role: .destructive) {
                        viewModel.onOptionDelete(option)
                    }
                }
            }
        }
    }
}

#Preview("Object") {
    ObjectPropertyListView(
        data: ObjectPropertyListData(
            configuration: PropertyModuleConfiguration.default,
            interactor: ObjectPropertyListInteractor(spaceId: "spaceId", limitedObjectTypes: []),
            relationSelectedOptionsModel: PropertySelectedOptionsModel(
                config: PropertyModuleConfiguration.default,
                selectedOptionsIds: []
            )
        ),
        output: nil
    )
}

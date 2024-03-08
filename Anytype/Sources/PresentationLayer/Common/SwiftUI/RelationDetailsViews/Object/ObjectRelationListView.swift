import SwiftUI
import WrappingHStack
import Services

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
                    .deleteDisabled(option.disableDeletion)
            }
            .onDelete {
                viewModel.onOptionDelete(with: $0)
            }
        }
    }
    
    @ViewBuilder
    private var header: some View {
        if viewModel.configuration.isEditable, let items = viewModel.objectRelationTypeItems() {
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
    
    private func optionRow(with option: ObjectRelationOption) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                ObjectRelationOptionView(option: option)
                
                Spacer()
                
                if viewModel.configuration.isEditable {
                    RelationListSelectionView(
                        selectionMode: viewModel.configuration.selectionMode,
                        selectedIndex: viewModel.selectedOptionsIds.firstIndex(of: option.id)
                    )
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

extension ObjectRelationListView {
    init(
        objectId: String,
        limitedObjectTypes: [ObjectType],
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListModuleOutput?
    ) {
        let interactor = ObjectRelationListInteractor(
            spaceId: configuration.spaceId,
            limitedObjectTypes: limitedObjectTypes
        )
        let relationSelectedOptionsModel = RelationSelectedOptionsModel(
            objectId: objectId,
            selectionMode: configuration.selectionMode,
            selectedOptionsIds: selectedOptionsIds,
            relationKey: configuration.relationKey,
            analyticsType: configuration.analyticsType
        )
        _viewModel = StateObject(
            wrappedValue: ObjectRelationListViewModel(
                configuration: configuration,
                interactor: interactor,
                relationSelectedOptionsModel: relationSelectedOptionsModel,
                output: output
            )
        )
    }
}

#Preview("Object") {
    SelectRelationListView(
        viewModel: SelectRelationListViewModel(
            style: .status,
            configuration: RelationModuleConfiguration.default,
            relationSelectedOptionsModel: RelationSelectedOptionsModel(
                objectId: "",
                selectionMode: .multi,
                selectedOptionsIds: [],
                relationKey: "",
                analyticsType: .block
            ),
            output: nil
        )
    )
}

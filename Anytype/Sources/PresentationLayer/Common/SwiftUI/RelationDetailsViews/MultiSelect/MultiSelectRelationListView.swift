import SwiftUI

struct MultiSelectRelationListView: View {
    
    @StateObject var viewModel: MultiSelectRelationListViewModel
    
    var body: some View {
        RelationListContainerView(
            title: viewModel.configuration.title, 
            isEditable: viewModel.configuration.isEditable,
            isEmpty: viewModel.isEmpty,
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
            viewModel.searchTextChanged()
        }
    }
    
    private func optionRow(with option: MultiSelectRelationOption) -> some View {
        Button {
            viewModel.optionSelected(option.id)
        } label: {
            HStack {
                AnytypeText(option.text, style: .relation1Regular, color: option.textColor)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .background(option.backgroundColor)
                    .cornerRadius(3)
                    .if(option.backgroundColor == Color.VeryLight.default) {
                        $0.overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.Stroke.primary, lineWidth: 1)
                        )
                    }
                    .frame(height: 20)
                
                Spacer()
                
                if viewModel.configuration.isEditable, let index = viewModel.selectedOptions.firstIndex(of: option.id) {
                    SelectionIndicatorView(model: .selected(index: index + 1, color: Color.System.sky))
                } else {
                    SelectionIndicatorView(model: .notSelected)
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
    MultiSelectRelationListView(
        viewModel: MultiSelectRelationListViewModel(
            configuration: RelationModuleConfiguration(
                title: "Tag",
                isEditable: true,
                relationKey: "",
                spaceId: "",
                analyticsType: .block
            ),
            selectedOptions: [],
            output: nil,
            relationsService: DI.preview.serviceLocator.relationService(objectId: ""),
            searchService: DI.preview.serviceLocator.searchService()
        )
    )
}

import SwiftUI

enum ItemPickerGridViewContants {
    static let gridItemHeight = 112.0
}

struct ItemPickerGridView<ViewModel: GridItemViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var searchText = ""

    private let columns: [GridItem] = {
        if UIDevice.isPad {
            return [GridItem(.adaptive(minimum: 200), spacing: 16)]
        } else {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible())
            ]
        }
    }()
    
    var body: some View {
        if case let .available(placeholder) = viewModel.searchAvailability {
            SearchBar(text: $searchText, focused: false, placeholder: placeholder)
        }
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 0) {
                sections
            }
        }
        .padding(.horizontal, 16)
        .onAppear { viewModel.onAppear() }
        .onChange(of: searchText) { _, newValue in
            viewModel.didChangeSearchQuery(query: newValue)
        }
    }

    private var sections: some View {
        ForEach(viewModel.sections) { section in
            if let title = section.title {
                Section(header: PickerSectionHeaderView(title: title)) {
                    sectionItems(items: section.items)
                }
            } else {
                sectionItems(items: section.items)
            }
        }
    }

    private func sectionItems(items: [ViewModel.Item]) -> some View {
        ForEach(items) { item in
            item.view
                .applyCoverGridItemAppearance()
                .onTapGesture {
                    viewModel.didSelectItem(item: item)
                }
        }
        .padding(.top, 16)
    }
}

private extension View {
    func applyCoverGridItemAppearance() -> some View {
        self
            .frame(height: ItemPickerGridViewContants.gridItemHeight)
            .cornerRadius(4)
    }
}

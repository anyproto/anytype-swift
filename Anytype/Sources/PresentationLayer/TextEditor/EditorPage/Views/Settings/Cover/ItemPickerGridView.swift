import SwiftUI

struct ItemPickerGridView<ViewModel: GridItemViewModelProtocol>: View {
    let viewModel: ViewModel
    
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
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: columns,
                spacing: 0,
                pinnedViews: [.sectionHeaders]
            ) {
                sections
            }
        }
        .padding(.horizontal, 16)
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
                .onTapGesture {
                    viewModel.didSelectItem(item: item)
                }
        }
        .padding(.top, 16)
    }
}

extension View {
    func applyCoverGridItemAppearance() -> some View {
        self
            .cornerRadius(4)
            .frame(height: 112)
    }
}

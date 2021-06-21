import SwiftUI

struct BlockToolbarAddBlockInputView: View {
    typealias Types = BlockToolbarBlocksTypes
    typealias TypesColor = Types.Resources.Color

    private var safeCategoryIndex: Int { categoryIndex ?? 0 }

    @ObservedObject var model: BlockToolbarAddBlockViewModel
    @Binding var categoryIndex: Int?
    @Binding var typeIndex: Int?

    var title: String
    var categories: [Types] = []
    var types: [(Int, BlockToolbarAddBlockViewModel.ChosenType)] {
        let values = self._model.wrappedValue.chosenTypes(category: self.$categoryIndex.wrappedValue)
        return Array(values.enumerated())
    }

    func typesSelected() -> Bool {
        !self.categoryIndex.isNil
    }

    var body: some View {
        List {
            ForEach(self.categories.indices) { i in
                /// NOTES:
                /// Interesting bug.
                /// Each cell should be identifiable by something.
                /// As soon as we doesn't know about top-level index, we should provide an identifier.
                /// If it doesn't happen, well, we are going wild.
                /// Cell *may* be reused and you see a cell in incorrect category.
                BlockToolbarAddBlockCategory(
                    viewModel: .init(title: self.categories[i].title),
                    cells: self.model.cells(category: i)
                )
            }
        }.onAppear {
            /// Thanks! https://stackoverflow.com/a/58474518
            // TODO: We should remove all appearances to global UIKit classes
            UITableView.appearance().tableFooterView = .init()
            UITableViewHeaderFooterView.appearance().tintColor = .clear
        }
    }
}

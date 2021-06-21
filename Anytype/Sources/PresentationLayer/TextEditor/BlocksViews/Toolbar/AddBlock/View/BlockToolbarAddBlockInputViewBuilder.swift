import SwiftUI

enum BlockToolbarAddBlockInputViewBuilder {
    static func createView(_ viewModel: ObservedObject<BlockToolbarAddBlockViewModel>) -> UIView? {
        let inputView = BlockToolbarAddBlockInputView(
            model: viewModel.wrappedValue,
            categoryIndex: viewModel.projectedValue.categoryIndex,
            typeIndex: viewModel.projectedValue.typeIndex,
            title: viewModel.wrappedValue.title,
            categories: viewModel.wrappedValue.categories
        )
        let controller = UIHostingController(rootView: inputView)
        let view = controller.view
        view?.backgroundColor = BlockToolbar.backgroundColor()
        return view
    }
}

import UIKit

struct MultiSelectionPaneSelectionAssembly {
    private(set) var viewModel: MultiSelectionPaneSelectionViewModel
    
    func buildView() -> UIView {
        MultiSelectionPaneSelectionView(viewModel: viewModel)
    }
    
    func buildDoneBarButton() -> UIBarButtonItem {
        MultiSelectionPane.Panes.Selection.Done.BarButtonItem.init(viewModel: viewModel.doneViewModel())
    }
    
    func buildSelectAllBarButton() -> UIBarButtonItem {
        MultiSelectionPane.Panes.Selection.SelectAll.BarButtonItem.init(viewModel: viewModel.selectAllViewModel())
    }
}

import UIKit

struct MultiSelectionPaneSelectionAssembly {
    private(set) var viewModel: MultiSelectionPaneSelectionViewModel
    
    func buildView() -> UIView {
        MultiSelectionPaneSelectionView(viewModel: viewModel)
    }
    
    func buildDoneBarButton() -> UIBarButtonItem {
        MultiSelectionPaneDoneBarButtonItem(viewModel: viewModel.doneViewModel())
    }
    
    func buildSelectAllBarButton() -> UIBarButtonItem {
        MultiSelectionPaneSelectAllBarButtonItem(viewModel: viewModel.selectAllViewModel())
    }
}

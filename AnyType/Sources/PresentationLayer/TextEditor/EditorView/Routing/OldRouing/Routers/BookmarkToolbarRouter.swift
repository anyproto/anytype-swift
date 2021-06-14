import UIKit

class BookmarkToolbarRouter {
    private weak var baseController: UIViewController?
    init(baseController: UIViewController?) {
        self.baseController = baseController
    }
    
    func hanlde(bookmarkOutput: BookmarkOutput) {
        let viewModel = BlocksViews.Toolbar.ViewController.ViewModel(.init(style: .bookmark))
        
        /// We want to receive values.
        viewModel.subscribe(subject: bookmarkOutput, keyPath: \.action)
        
        let controller = BlocksViews.Toolbar.ViewController(model: viewModel)
        baseController?.present(controller, animated: true, completion: nil)
    }
}

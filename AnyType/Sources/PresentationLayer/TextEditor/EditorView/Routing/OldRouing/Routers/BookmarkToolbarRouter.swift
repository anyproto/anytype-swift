import UIKit

class BookmarkToolbarRouter {
    private weak var mainController: UIViewController?
    init(vc: UIViewController?) {
        self.mainController = vc
    }
    
    func hanlde(bookmark: BlocksViews.UserAction.Bookmark) {
        let viewModel = BlocksViews.Toolbar.ViewController.ViewModel(.init(style: .bookmark))
        
        let subject = bookmark.output
        
        /// We want to receive values.
        viewModel.subscribe(subject: subject, keyPath: \.action)
        
        let controller = BlocksViews.Toolbar.ViewController(model: viewModel)
        mainController?.present(controller, animated: true, completion: nil)
    }
}

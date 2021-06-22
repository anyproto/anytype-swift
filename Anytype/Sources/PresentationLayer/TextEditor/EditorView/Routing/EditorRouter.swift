import UIKit
import BlocksModels
import SafariServices
import Combine

/// Presenting new view on screen in editor
protocol EditorRouterProtocol {
    func showPage(with id: BlockId)
    func openUrl(_ url: URL)
    func showBookmark(actionsSubject: PassthroughSubject<BlockToolbarAction, Never>)
    func file(action: BlockUserAction.FileAction)
}


final class EditorRouter: EditorRouterProtocol {
    private weak var preseningViewController: UIViewController?
    private let fileRouter: FileRouter

    init(preseningViewController: UIViewController) {
        self.preseningViewController = preseningViewController
        self.fileRouter = FileRouter(fileLoader: FileLoader(), viewController: preseningViewController)
    }

    /// Show page
    func showPage(with id: BlockId) {
        let presentedDocumentView = EditorAssembly.build(id: id)
        // TODO: - show?? Really?
        preseningViewController?.show(presentedDocumentView, sender: nil)
    }
    
    func openUrl(_ url: URL) {
        guard url.containsHttpProtocol else {
            return
        }
        
        let safariController = SFSafariViewController(url: url)
        preseningViewController?.present(safariController, animated: true, completion: nil)
    }
    
    func showBookmark(actionsSubject: PassthroughSubject<BlockToolbarAction, Never>) {
        let viewModel = BookmarkToolbarViewModel()
        
        /// We want to receive values.
        viewModel.subscribe(subject: actionsSubject, keyPath: \.action)
        
        let controller = BookmarkViewController(model: viewModel)
        preseningViewController?.present(controller, animated: true, completion: nil)
    }
    
    func file(action: BlockUserAction.FileAction) {
        fileRouter.handle(action: action)
    }
}

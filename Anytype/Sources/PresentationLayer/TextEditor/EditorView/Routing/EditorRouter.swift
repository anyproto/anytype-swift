import UIKit
import BlocksModels
import SafariServices

/// Presenting new view on screen in editor
protocol EditorRouterProtocol {
    func showPage(with id: BlockId)
    func openUrl(_ url: URL)
}


final class EditorRouter: EditorRouterProtocol {
    private weak var preseningViewController: UIViewController?

    init(preseningViewController: UIViewController) {
        self.preseningViewController = preseningViewController
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
}

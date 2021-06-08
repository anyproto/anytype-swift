import UIKit
import BlocksModels

/// Presenting new view on screen in editor
protocol EditorRouterProtocol {
    func showPage(with id: BlockId)
}


final class EditorRouter: EditorRouterProtocol {
    private weak var preseningViewController: UIViewController?

    init(preseningViewController: UIViewController) {
        self.preseningViewController = preseningViewController
    }

    /// Show page
    func showPage(with id: BlockId) {
        let presentedDocumentView = EditorModuleContainerViewBuilder.view(id: id)
        // TODO: - show?? Really?
        preseningViewController?.show(presentedDocumentView, sender: nil)
    }
}

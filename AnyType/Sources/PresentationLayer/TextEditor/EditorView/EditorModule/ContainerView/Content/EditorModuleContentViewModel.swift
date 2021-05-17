import Foundation
import UIKit
import Combine


class EditorModuleContentViewModel {
    private let selectionPresenter: EditorSelectionToolbarPresenter
    private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
    var selectionAction: AnyPublisher<EditorSelectionToolbarPresenter.SelectionAction, Never> {
        self.selectionPresenter.userAction
    }
    
    init(topBottomMenuViewController controller: TopBottomMenuViewController) {
        self.selectionPresenter = EditorSelectionToolbarPresenter(
            topBottomMenuViewController: controller,
            selectionEventPublisher: self.selectionHandler.selectionEventPublisher()
        )
    }

    // MARK: Configurations
    func configured(navigationItem: UINavigationItem) {
        self.selectionPresenter.navigationItem = navigationItem
    }
}


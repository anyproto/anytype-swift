import Foundation
import UIKit
import Combine


class EditorModuleContentViewModel {
    private let selectionPresenter: EditorSelectionToolbarPresenter
    private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
    var selectionAction: AnyPublisher<EditorSelectionToolbarPresenter.SelectionAction, Never> {
        self.selectionPresenter.userAction
    }
    
    init(bottomMenuViewController controller: BottomMenuViewController) {
        self.selectionPresenter = EditorSelectionToolbarPresenter(
            bottomMenuViewController: controller,
            selectionEventPublisher: self.selectionHandler.selectionEventPublisher()
        )
    }

    // MARK: Configurations
    func configured(navigationItem: UINavigationItem) {
        self.selectionPresenter.navigationItem = navigationItem
    }
}


import Foundation
import UIKit
import Combine


class EditorModuleContentViewModel {
    /// And keep selection here.
    private var selectionPresenter = EditorSelectionToolbarPresenter()
    private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol = EditorSelectionHandler()
    var selectionAction: AnyPublisher<EditorSelectionToolbarPresenter.SelectionAction, Never> {
        self.selectionPresenter.userAction
    }
    
    // MARK: - Setup
    func setup() {
        _ = self.configured(selectionEventsPublisher: self.selectionHandler.selectionEventPublisher())
    }
    
    init() {
        self.setup()
    }

    // MARK: Configurations
    func configured(navigationItem: UINavigationItem) -> Self {
        _ = self.selectionPresenter.configured(navigationItem: navigationItem)
        return self
    }
    func configured(topBottomMenuViewController controller: TopBottomMenuViewController) -> Self {
        _ = self.selectionPresenter.configured(topBottomMenuViewController: controller)
        return self
    }
    private func configured(selectionEventsPublisher: AnyPublisher<EditorSelectionIncomingEvent, Never>) -> Self {
        _ = self.selectionPresenter.configured(selectionEventPublisher: selectionEventsPublisher)
        return self
    }
}


import Foundation
import UIKit
import Combine


class EditorModuleContentViewModel {
    /// And keep selection here.
    private var selectionPresenter: EditorModule.Selection.ToolbarPresenter = .init()
    private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol = EditorModule.Selection.Handler.init()
    var selectionAction: AnyPublisher<EditorModule.Selection.ToolbarPresenter.SelectionAction, Never> {
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
    func configured(topBottomMenuViewController controller: EditorModule.TopBottomMenuViewController) -> Self {
        _ = self.selectionPresenter.configured(topBottomMenuViewController: controller)
        return self
    }
    private func configured(selectionEventsPublisher: AnyPublisher<EditorModule.Selection.IncomingEvent, Never>) -> Self {
        _ = self.selectionPresenter.configured(selectionEventPublisher: selectionEventsPublisher)
        return self
    }
}


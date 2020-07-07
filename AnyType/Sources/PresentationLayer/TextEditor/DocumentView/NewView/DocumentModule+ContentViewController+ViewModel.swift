//
//  DocumentModule+ContentViewController+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = DocumentModule

// MARK: ViewModel
extension Namespace.ContentViewController {
    class ViewModel {
        /// And keep selection here.
        private var selectionPresenter: DocumentModule.Selection.ToolbarPresenter = .init()
        private(set) var selectionHandler: DocumentModuleSelectionHandlerProtocol = Namespace.Selection.Handler.init()
        var selectionAction: AnyPublisher<DocumentModule.Selection.ToolbarPresenter.SelectionAction, Never> {
            self.selectionPresenter.userAction
        }
        
        // MARK: - Setup
        func setup() {
            _ = self.configured(selectionEventsPublisher: self.selectionHandler.selectionEventPublisher())
        }
        
        // MARK: - Initialization
        init() {
            self.setup()
        }
    }
}

// MARK: Configurations
extension Namespace.ContentViewController.ViewModel {
    func configured(navigationItem: UINavigationItem) -> Self {
        _ = self.selectionPresenter.configured(navigationItem: navigationItem)
        return self
    }
    func configured(topBottomMenuViewController controller: DocumentModule.TopBottomMenuViewController) -> Self {
        _ = self.selectionPresenter.configured(topBottomMenuViewController: controller)
        return self
    }
    private func configured(selectionEventsPublisher: AnyPublisher<DocumentModule.Selection.IncomingEvent, Never>) -> Self {
        _ = self.selectionPresenter.configured(selectionEventPublisher: selectionEventsPublisher)
        return self
    }
}


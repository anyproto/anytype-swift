//
//  EditorModule+Content+ViewController+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias DocumentNamespace = EditorModule
fileprivate typealias Namespace = EditorModule.Content.ViewController

// MARK: ViewModel
extension Namespace {
    class ViewModel {
        /// And keep selection here.
        private var selectionPresenter: EditorModule.Selection.ToolbarPresenter = .init()
        private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol = DocumentNamespace.Selection.Handler.init()
        var selectionAction: AnyPublisher<EditorModule.Selection.ToolbarPresenter.SelectionAction, Never> {
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
extension Namespace.ViewModel {
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


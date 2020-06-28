//
//  DocumentModule+Selection+ToolbarPresenter.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = DocumentModule.Selection

/// This selection handler is intended to show controls.
///
extension Namespace {
    class ToolbarPresenter {
        private var subscription: AnyCancellable?
        weak private var topBottomMenuViewController: DocumentModule.TopBottomMenuViewController?
        typealias SelectionAction = MultiSelectionPane.UIKit.Main.Action
        typealias SelectionEvent = DocumentModule.Selection.IncomingEvent
        private var multiSelectionAssembly: MultiSelectionPane.UIKit.Main.Assembly = .init()
        
        /// Subscribe on UserAction.
        var userAction: AnyPublisher<SelectionAction, Never> {
            return self.multiSelectionAssembly.viewModel.userAction
        }
        
        // TODO: Make Private?
        private func update(selectedCount: Int) {
            self.multiSelectionAssembly.viewModel.handle(countOfObjects: selectedCount)
        }
        
        private func selectionNotShown() -> Bool {
            self.topBottomMenuViewController?.menusState() == .some(.none)
        }
        
        private func update(selectionEnabled: Bool) {
            guard let controller = self.topBottomMenuViewController else { return }
            
            if selectionEnabled {
                let selectionView = self.multiSelectionAssembly.selectionView()
                
                let toolbarView = self.multiSelectionAssembly.toolbarView()
                controller.add(subview: selectionView, onToolbar: .top)
                controller.add(subview: toolbarView, onToolbar: .bottom)
            }
            else {
                controller.removeSubview(fromToolbar: .top)
                controller.removeSubview(fromToolbar: .bottom)
            }
        }
        
        private func update(selectionEnabled: Bool, completion: @escaping (Bool) -> ()) {
            self.update(selectionEnabled: selectionEnabled)
        }
        
        private func update(selectionEvent: SelectionEvent) {
            switch selectionEvent {
            case .selectionDisabled:
                self.update(selectionEnabled: false, completion: { _ in })
            case let .selectionEnabled(value):
                if self.selectionNotShown() {
                    self.update(selectionEnabled: true, completion: { _ in })
                }
                switch value {
                case .isEmpty: self.update(selectedCount: 0)
                case let .nonEmpty(value): self.update(selectedCount: .init(value))
                }
            }
        }
    }
}

// MARK: Configurations
extension Namespace.ToolbarPresenter {
    func configured(topBottomMenuViewController: DocumentModule.TopBottomMenuViewController?) -> Self {
        self.topBottomMenuViewController = topBottomMenuViewController
        return self
    }
    
    func configured(selectionEventPublisher: AnyPublisher<SelectionEvent, Never>) -> Self {
        self.subscription = selectionEventPublisher.sink(receiveValue: { [weak self] (value) in
            self?.update(selectionEvent: value)
        })
        return self
    }
}

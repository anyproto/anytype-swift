//
//  DocumentViewController+New+SelectionHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = DocumentModule.DocumentViewController

/// This selection handler is intended to show controls.
///
extension Namespace {
    class SelectionHandler {
        private var subscription: AnyCancellable?
        weak private var tableView: UITableView?
        typealias SelectionAction = MultiSelectionPane.UIKit.Main.Action
        typealias SelectionEvent = DocumentModule.SelectionEvent
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
            self.tableView?.tableFooterView == nil || self.tableView?.tableHeaderView == nil
        }
        
        private func update(selectionEnabled: Bool) {
            guard let tableView = self.tableView else { return }
            
            if selectionEnabled {
                let toolbarView = self.multiSelectionAssembly.toolbarView()
                let selectionView = self.multiSelectionAssembly.selectionView()
                let zero: CGPoint = .zero
                var size = toolbarView.systemLayoutSizeFitting(.zero)
                var frame = toolbarView.frame
                frame.origin = zero
                frame.size = size
                toolbarView.frame = frame
                
                size = selectionView.systemLayoutSizeFitting(.zero)
                frame = selectionView.frame
                
                frame.origin = zero
                frame.size = size
                selectionView.frame = frame
                tableView.tableFooterView = toolbarView
                tableView.tableHeaderView = selectionView
            }
            else {
                tableView.tableFooterView = nil
                tableView.tableHeaderView = nil
            }
        }
        
        private func update(selectionEnabled: Bool, completion: @escaping (Bool) -> ()) {
            // Add animation
            UIView.animate(withDuration: 0.3, animations: {
                self.update(selectionEnabled: selectionEnabled)
            }, completion: completion)
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
extension Namespace.SelectionHandler {
    func configured(tableView: UITableView?) -> Self {
        self.tableView = tableView
        return self
    }
    
    func configured(selectionEventPublisher: AnyPublisher<SelectionEvent, Never>) -> Self {
        self.subscription = selectionEventPublisher.sink(receiveValue: { [weak self] (value) in
            self?.update(selectionEvent: value)
        })
        return self
    }
}

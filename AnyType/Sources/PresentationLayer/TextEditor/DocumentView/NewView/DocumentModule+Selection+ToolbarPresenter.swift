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
        
        struct RestorationPoint {
            var leftBarButtons: [UIBarButtonItem]?
            var rightBarButtons: [UIBarButtonItem]?
            
            mutating func save(_ navigationItem: UINavigationItem) {
                self.leftBarButtons = navigationItem.leftBarButtonItems
                self.rightBarButtons = navigationItem.rightBarButtonItems
            }
            func apply(_ navigationItem: UINavigationItem) {
                navigationItem.leftBarButtonItems = self.leftBarButtons
                navigationItem.rightBarButtonItems = self.rightBarButtons
            }
        }
                
        
        /// Aliases
        typealias SelectionAction = MultiSelectionPane.UIKit.Main.Action
        typealias SelectionEvent = DocumentModule.Selection.IncomingEvent

        /// Variables
        private var subscription: AnyCancellable?
        private var multiSelectionAssembly: MultiSelectionPane.UIKit.Main.Assembly = .init()
        private var restorationPoint: RestorationPoint = .init()
        
        /// Variables / Targets
        private weak var topBottomMenuViewController: DocumentModule.TopBottomMenuViewController?
        private weak var navigationItem: UINavigationItem?
        
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
            guard let controller = self.topBottomMenuViewController, let navigationItem = self.navigationItem else { return }
            
            if selectionEnabled {
//                let selectionView = self.multiSelectionAssembly.selectionView()
                let leftBarButtonItem = self.multiSelectionAssembly.selectionAssembly.buildBarButtonItem(of: .selectAll)
                let rightBarButtonItem = self.multiSelectionAssembly.selectionAssembly.buildBarButtonItem(of: .done)
                
                let toolbarView = self.multiSelectionAssembly.toolbarView()
//                controller.add(subview: selectionView, onToolbar: .top)
                
//                navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
//                navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
                self.restorationPoint.save(navigationItem)
                navigationItem.leftBarButtonItem = leftBarButtonItem
                navigationItem.rightBarButtonItem = rightBarButtonItem
                
                controller.add(subview: toolbarView, onToolbar: .bottom)
            }
            else {
//                controller.removeSubview(fromToolbar: .top)
//                navigationController.setNavigationBarHidden(true, animated: true)
                self.restorationPoint.apply(navigationItem)
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
    
    func configured(navigationItem: UINavigationItem?) -> Self {
        self.navigationItem = navigationItem
        return self
    }
    
    func configured(selectionEventPublisher: AnyPublisher<SelectionEvent, Never>) -> Self {
        self.subscription = selectionEventPublisher.sink(receiveValue: { [weak self] (value) in
            self?.update(selectionEvent: value)
        })
        return self
    }
}

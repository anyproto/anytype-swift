//
//  EditorModule+Selection+ToolbarPresenter.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = EditorModule.Selection

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
        typealias SelectionEvent = EditorModule.Selection.IncomingEvent

        /// Variables
        private var subscription: AnyCancellable?
        private var multiSelectionAssembly: MultiSelectionPane.UIKit.Main.Assembly = .init()
        private var restorationPoint: RestorationPoint = .init()
        
        /// Variables / Targets
        private weak var topBottomMenuViewController: EditorModule.TopBottomMenuViewController?
        private weak var navigationItem: UINavigationItem?
        
        /// Subscribe on UserAction.
        var userAction: AnyPublisher<SelectionAction, Never> {
            return self.multiSelectionAssembly.viewModel.userAction
        }
        
        // TODO: Make Private?
        private func update(selectedCount: Int, turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes]) {
            self.multiSelectionAssembly.viewModel.handle(countOfObjects: selectedCount, turnIntoStyles: turnIntoStyles)
        }
        
        private func selectionNotShown() -> Bool {
            self.topBottomMenuViewController?.menusState() == .some(.none)
        }
                
        private func update(selectionEnabled: Bool) {
            guard let controller = self.topBottomMenuViewController, let navigationItem = self.navigationItem else { return }
            
            if selectionEnabled {
                let leftBarButtonItem = self.multiSelectionAssembly.selectionAssembly.buildBarButtonItem(of: .selectAll)
                let rightBarButtonItem = self.multiSelectionAssembly.selectionAssembly.buildBarButtonItem(of: .done)
                
                let toolbarView = self.multiSelectionAssembly.toolbarView()
                self.restorationPoint.save(navigationItem)
                navigationItem.leftBarButtonItem = leftBarButtonItem
                navigationItem.rightBarButtonItem = rightBarButtonItem
                
                controller.add(subview: toolbarView, onToolbar: .bottom)
            }
            else {
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
                case .isEmpty: self.update(selectedCount: 0, turnIntoStyles: [])
                case let .nonEmpty(count, turnIntoStyles): self.update(selectedCount: .init(count), turnIntoStyles: turnIntoStyles)
                }
            }
        }
    }
}

// MARK: Configurations
extension Namespace.ToolbarPresenter {
    func configured(topBottomMenuViewController: EditorModule.TopBottomMenuViewController?) -> Self {
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

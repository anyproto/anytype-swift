//
//  DocumentViewRouting+Toolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: ToolbarsRouter
extension DocumentViewRouting {
    /// This router is processing to process .toolbars actions.
    ///
    class ToolbarsRouter: BaseCompoundRouter {
        typealias BaseRouter = DocumentViewRouting.BaseRouter
        
        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .toolbars(.addBlock): return self.router(of: AddBlockToolbarRouter.self)
            case .toolbars(.turnIntoBlock): return self.router(of: TurnIntoToolbarRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [AddBlockToolbarRouter(), TurnIntoToolbarRouter()]
        }
    }
}

// MARK: ToolbarsRouter / AddBlockToolbarRouter
extension DocumentViewRouting.ToolbarsRouter {
    /// It is processing AddBlock toolbar appearing.
    ///
    class AddBlockToolbarRouter: BaseRouter {
        /// Custom UINavigationBar for AddBlock toolbar.
        ///
        private class NavigationBar: UINavigationBar {}
        
        private func handle(action: BlocksViews.UserAction.ToolbarOpenAction) {
            switch action {
            case .addBlock:
                let viewModel: BlocksViews.Toolbar.ViewController.ViewModel = .create(.addBlock)
                let controller = BlocksViews.Toolbar.ViewController.init(model: viewModel)
                
                // TODO: Rethink.
                // Should we configure appearance of controller here?
                let appearance = NavigationBar.appearance()
                appearance.tintColor = .black
                appearance.backgroundColor = .white
                appearance.isTranslucent = false
                let viewController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
                viewController.viewControllers = [controller]
                self.send(event: .showViewController(viewController))
            default: return
            }
        }
        
        // MARK: Subclassing
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value) where value == .addBlock: self.handle(action: value)
            default: return
            }
        }
    }
}

// MARK: ToolbarsRouter / TurnIntoToolbarRouter
extension DocumentViewRouting.ToolbarsRouter {
    /// It is processing TurnInto toolbar appearing.
    ///
    class TurnIntoToolbarRouter: BaseRouter {
        /// Custom UINavigationBar for TurnInto toolbar.
        ///
        private class NavigationBar: UINavigationBar {}
        
        private func handle(action: BlocksViews.UserAction.ToolbarOpenAction) {
            switch action {
            case .turnIntoBlock:
                let viewModel: BlocksViews.Toolbar.ViewController.ViewModel = .create(.turnIntoBlock)
                let controller = BlocksViews.Toolbar.ViewController.init(model: viewModel)
                
                // TODO: Rethink.
                // Should we configure appearance of controller here?
                let appearance = NavigationBar.appearance()
                appearance.tintColor = .black
                appearance.backgroundColor = .white
                appearance.isTranslucent = false
                let viewController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
                viewController.viewControllers = [controller]
                self.send(event: .showViewController(viewController))
            default: return
            }
        }
        
        // MARK: Subclassing
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value) where value == .turnIntoBlock: self.handle(action: value)
            default: return
            }
        }
    }
}

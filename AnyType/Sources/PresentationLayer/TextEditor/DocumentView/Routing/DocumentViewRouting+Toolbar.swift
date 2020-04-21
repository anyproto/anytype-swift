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
         
        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .toolbars(.addBlock): return self.router(of: AddBlockToolbarRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [AddBlockToolbarRouter()]
        }
    }
}

// MARK: ToolbarsRouter / AddBlockToolbarRouter
extension DocumentViewRouting.ToolbarsRouter {
    typealias BaseRouter = DocumentViewRouting.BaseRouter
    
    /// Custom UINavigationBar for AddBlock toolbar.
    ///
    private class NavigationBar: UINavigationBar {}
    
    /// It is processing AddBlock toolbar appearing.
    ///
    class AddBlockToolbarRouter: BaseRouter {
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
            }
        }
        
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value): self.handle(action: value)
            default: return
            }
        }
    }
}

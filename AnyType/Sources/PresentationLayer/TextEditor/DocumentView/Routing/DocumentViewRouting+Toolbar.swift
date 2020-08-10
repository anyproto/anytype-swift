//
//  DocumentViewRouting+Toolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

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
            case .toolbars(.marksPane): return self.router(of: MarksPaneToolbarRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [AddBlockToolbarRouter(), TurnIntoToolbarRouter(), MarksPaneToolbarRouter()]
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
            case let .turnIntoBlock(payload):
                let viewModel: BlocksViews.Toolbar.ViewController.ViewModel
                if let input = payload.input {
                    var style: BlocksViews.Toolbar.ViewController.ViewModel.Style = .turnIntoBlock
                    style = style.configured(input.payload.filtering)
                    viewModel = .create(style)
                }
                else {
                    viewModel = .create(.turnIntoBlock)
                }
                
                let controller = BlocksViews.Toolbar.ViewController.init(model: viewModel)
                let subject = payload.output
                
                /// NOTE: Tough point.
                /// We have a view model here.
                /// It could publish action, suppose, it is `.$action` publisher.
                /// Next, we would like to send events to a subject that is coming in associated value.
                /// Again, somebody need to keep this subscription.
                /// In our case, we choose viewModel.
                ///
                /// ViewModel.action -> Publish Action.
                /// Subject <- Published Action.
                /// ViewModel.subscription = subject.send(ViewModel.action.publishedValue)
                viewModel.subscribe(subject: subject, keyPath: \.action)
                
                // TODO: Rethink.
                // Should we configure appearance of controller here?
                let appearance = NavigationBar.appearance()
                appearance.tintColor = .black
                appearance.backgroundColor = .white
                appearance.isTranslucent = false
                let viewController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
                viewController.viewControllers = [controller]
                self.send(event: .general(.show(viewController)))
            default: return
            }
        }

        // MARK: Subclassing
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value):
                switch value {
                case .turnIntoBlock: self.handle(action: value)
                default: return
                }
            default: return
            }
        }
    }
}

// MARK: ToolbarsRouter / AddBlockRouter
extension DocumentViewRouting.ToolbarsRouter {
    /// It is processing AddBlock toolbar appearing.
    ///
    class AddBlockToolbarRouter: BaseRouter {
        /// Custom UINavigationBar for AddBlock toolbar.
        ///
        private class NavigationBar: UINavigationBar {}
                
        private func handle(action: BlocksViews.UserAction.ToolbarOpenAction) {
            switch action {
            case let .addBlock(payload):
                let viewModel: BlocksViews.Toolbar.ViewController.ViewModel = .create(.addBlock)
                let controller = BlocksViews.Toolbar.ViewController.init(model: viewModel)
                
                let subject = payload.output
                
                /// NOTE: Tough point.
                /// We have a view model here.
                /// It could publish action, suppose, it is `.$action` publisher.
                /// Next, we would like to send events to a subject that is coming in associated value.
                /// Again, somebody need to keep this subscription.
                /// In our case, we choose viewModel.
                ///
                /// ViewModel.action -> Publish Action.
                /// Subject <- Published Action.
                /// ViewModel.subscription = subject.send(ViewModel.action.publishedValue)
                viewModel.subscribe(subject: subject, keyPath: \.action)
                
                // TODO: Rethink.
                // Should we configure appearance of controller here?
                let appearance = NavigationBar.appearance()
                appearance.tintColor = .black
                appearance.backgroundColor = .white
                appearance.isTranslucent = false
                let viewController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
                viewController.viewControllers = [controller]
                self.send(event: .general(.show(viewController)))
            default: return
            }
        }
        
        // MARK: Subclassing
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value):
                switch value {
                case .addBlock: self.handle(action: value)
                default: return
                }
            default: return
            }
        }
    }
}

// MARK: ToolbarsRouter / MarksPaneRouter
extension DocumentViewRouting.ToolbarsRouter {
    /// It is processing AddBlock toolbar appearing.
    ///
    class MarksPaneToolbarRouter: BaseRouter {
        /// Custom UINavigationBar for AddBlock toolbar.
        ///
        private class NavigationBar: UINavigationBar {}
                
        private func handle(action: BlocksViews.UserAction.ToolbarOpenAction) {
            switch action {
            case let .marksPane(.mainPane(payload)):
                let viewModel: MarksPane.ViewController.ViewModel = .create(.color)
                let controller: MarksPane.ViewController = .init(model: viewModel)
                
                let subject = payload.output
                
                /// NOTE: Tough point.
                /// We have a view model here.
                /// It could publish action, suppose, it is `.$action` publisher.
                /// Next, we would like to send events to a subject that is coming in associated value.
                /// Again, somebody need to keep this subscription.
                /// In our case, we choose viewModel.
                ///
                /// ViewModel.action -> Publish Action.
                /// Subject <- Published Action.
                /// ViewModel.subscription = subject.send(ViewModel.action.publishedValue)
                viewModel.subscribe(subject: subject, keyPath: \.action)
                
                // TODO: Move to MarksPane.ViewControllerBuilder or MarksPane.ViewBuilder
                let viewController = MarksPane.ViewController.configured(controller)
                self.send(event: .general(.show(viewController)))
            default: return
            }
        }
        
        // MARK: Subclassing
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value):
                switch value {
                case .marksPane: self.handle(action: value)
                default: return
                }
            default: return
            }
        }
    }
}

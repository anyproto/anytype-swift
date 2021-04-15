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
            case .toolbars(.bookmark): return self.router(of: BookmarkToolbarRouter.self)
            case .toolbars(.marksPane): return self.router(of: MarksPaneToolbarRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [AddBlockToolbarRouter(), TurnIntoToolbarRouter(), BookmarkToolbarRouter(), MarksPaneToolbarRouter()]
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
                let style = BlocksViews.Toolbar.ViewController.ViewModel.Style(style: .turnIntoBlock,
                                                                               filtering: payload.input?.payload.filtering)
                let viewModel = BlocksViews.Toolbar.ViewController.ViewModel(style)
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
                let viewModel = BlocksViews.Toolbar.ViewController.ViewModel(.init(style: .addBlock))
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

// MARK: ToolbarsRouter / BookmarkPaneRouter
extension DocumentViewRouting.ToolbarsRouter {
    /// It is processing Bookmark toolbar appearing.
    ///
    class BookmarkToolbarRouter: BaseRouter {
        private func hanlde(action: BlocksViews.UserAction.ToolbarOpenAction) {
            switch action {
            case let .bookmark(payload):
                let viewModel = BlocksViews.Toolbar.ViewController.ViewModel(.init(style: .bookmark))
                
                let subject = payload.output
                
                /// We want to receive values.
                viewModel.subscribe(subject: subject, keyPath: \.action)
                
                let controller: BlocksViews.Toolbar.ViewController = .init(model: viewModel)
                self.send(event: .general(.show(controller)))
                // Do stuff.
            default: return
            }
        }
        
        // MARK: Subclassing
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .toolbars(value):
                switch value {
                case .bookmark: self.hanlde(action: value)
                default: return
                }
            default: return
            }
        }
    }
}

// MARK: ToolbarsRouter / MarksPaneRouter
extension DocumentViewRouting.ToolbarsRouter {
    /// It is processing MarksPane toolbar appearing.
    ///
    class MarksPaneToolbarRouter: BaseRouter {
        /// Custom UINavigationBar for AddBlock toolbar.
        ///
        private class NavigationBar: UINavigationBar {}
                
        private func handle(action: BlocksViews.UserAction.ToolbarOpenAction) {
            switch action {
            case let .marksPane(.mainPane(payload)):
                let viewModel: MarksPane.ViewController.ViewModel
                
                if let input = payload.input {
                    viewModel = .create(.init(section: input.section, userResponse: input.userResponse))
                    if input.shouldPluginOutputIntoInput {
                        let publisher = payload.output.map({ value -> MarksPane.ViewController.ViewModel.Style? in
                            switch value {
                            case let .backgroundColor(_, action):
                                switch action {
                                case let .setColor(value):
                                    return .init(section: nil, userResponse: .init(backgroundColor: value))
                                }
                            default: return nil
                            }
                        }).eraseToAnyPublisher()
                        viewModel.configured(publisher)
                    }
                }
                else {
                    viewModel = .create(.init())
                }

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

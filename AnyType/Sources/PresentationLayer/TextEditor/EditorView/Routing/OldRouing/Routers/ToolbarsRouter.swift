import Foundation
import UIKit
import Combine

/// This router is processing to process .toolbars actions.
///
class ToolbarsRouter: DocumentViewBaseCompoundRouter {
    
    // MARK: Subclassing
    override func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? {
        switch action {
        case .toolbars(.addBlock): return self.router(of: AddBlockToolbarRouter.self)
        case .toolbars(.turnIntoBlock): return self.router(of: TurnIntoToolbarRouter.self)
        case .toolbars(.bookmark): return self.router(of: BookmarkToolbarRouter.self)
        case .toolbars(.marksPane):
            return nil
        case .specific:
            return nil
        }
    }
    override func defaultRouters() -> [DocumentViewBaseRouter] {
        [AddBlockToolbarRouter(), TurnIntoToolbarRouter(), BookmarkToolbarRouter()]
    }
}

// MARK: ToolbarsRouter / TurnIntoToolbarRouter
extension ToolbarsRouter {
    /// It is processing TurnInto toolbar appearing.
    ///
    class TurnIntoToolbarRouter: DocumentViewBaseRouter {
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
                appearance.tintColor = .grayscale90
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
extension ToolbarsRouter {
    /// It is processing AddBlock toolbar appearing.
    ///
    class AddBlockToolbarRouter: DocumentViewBaseRouter {
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
                appearance.tintColor = .grayscale90
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
extension ToolbarsRouter {
    /// It is processing Bookmark toolbar appearing.
    ///
    class BookmarkToolbarRouter: DocumentViewBaseRouter {
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

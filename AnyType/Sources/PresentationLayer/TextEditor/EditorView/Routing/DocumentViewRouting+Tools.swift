import Foundation
import Combine
import os


// MARK: ToolsBlocksViewsRouter
extension DocumentViewRouting {
    /// We use name "Tools" as legacy from old design.
    /// Previously, we have PageLink and Page entries in Tools category.
    /// Later we should move PageLink to new category Page.
    ///
    class ToolsBlocksViewsRouter: BaseCompoundRouter {

        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .specific(.tool): return self.router(of: PageLinkToolsBlocksViewsRouter.self)
            default: return nil
            }
        }
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [PageLinkToolsBlocksViewsRouter()]
        }
    }
}

// MARK: PageLinkToolsBlocksViewsRouters
extension DocumentViewRouting.ToolsBlocksViewsRouter {
    typealias BaseRouter = DocumentViewRouting.BaseRouter
    class PageLinkToolsBlocksViewsRouter: BaseRouter {
        private var subscription: AnyCancellable?
        private func handle(action: BlocksViews.UserAction.Tools.UserAction.PageLink) {
            switch action {
            case let .shouldShowPage(value):
                guard self.subscription == nil else {
                    /// Description:
                    /// What happening here.
                    ///
                    /// Somehow, after first "AddBlock/RemoveBlock", DocumentViewModel builders are changing theirselves and copy themselves into router subscription.
                    /// UserActionPublisher is a corner stone of all this disaster.
                    ///
                    /// Assumption:
                    /// When we change builders array, their publishers "retained" somehow.
                    /// So, instead of correct updates of builders, we have multiple copies of the same events.
                    /// Consider following:
                    ///
                    /// [a, b, c] - our view models.
                    ///
                    /// when update is coming, something is going wrong and we have incorrect state.
                    ///
                    /// [a, b, c, d, a, b, c] - new view models.
                    ///
                    /// But! Don't mess with view models in "their pure state".
                    ///
                    /// We have a set ( or array ) of their publishers...
                    ///
                    /// So, more correctly it would be the following:
                    ///
                    /// [a, b, c].map(\.publisher)
                    ///
                    /// [a, b, c].map(\.publisher) + [d, a, b, c].map(\.publisher)
                    ///
                    assertionFailure("Surely, It should be fixed in another way, but, it is ok for now.")
                    return
                }
                
                self.send(event: .document(.child(value)))
            }
        }

        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .specific(.tool(.pageLink(value))): self.handle(action: value)
            default: return
            }
        }
    }
}

//
//  DocumentViewRouting+Tools.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 06.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

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
        private func handle(action: ToolsBlocksViews.UserAction.PageLink) {
            switch action {
            case let .shouldShowPage(value):
                let viewController = DocumentViewBuilder.UIKitBuilder.documentView(by: .init(id: value, useUIKit: true))
                self.send(event: .pushViewController(viewController))
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

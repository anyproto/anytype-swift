//
//  DocumentViewRouting+Page.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 5/10/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: PageBlocksViewsRouter
extension DocumentViewRouting {
    
    class PageBlocksViewsRouter: BaseCompoundRouter {
         
        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case .specific(.page): return self.router(of: EmojiViewRouter.self)
            default: return nil
            }
        }
        
        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [EmojiViewRouter()]
        }
    }
    
}

// MARK: PageBlocksViewsRouter / EmojiRouter
extension DocumentViewRouting.PageBlocksViewsRouter {
    typealias BaseRouter = DocumentViewRouting.BaseRouter
    class EmojiViewRouter: BaseRouter {
        private func handle(action: PageBlocksViews.UserAction.EmojiAction) {
            switch action {
            case let .shouldShowEmojiPicker(model):
                let viewController = EmojiPicker.ViewController.init(viewModel: model)
                self.send(event: .general(.show(viewController)))
            }
        }
        
        override func receive(action: BlocksViews.UserAction) {
            switch action {
            case let .specific(.page(.emoji(value))): self.handle(action: value)
            default: return
            }
        }
    }
}

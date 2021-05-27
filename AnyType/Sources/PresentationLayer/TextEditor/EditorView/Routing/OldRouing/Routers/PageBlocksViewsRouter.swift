import Foundation

class PageBlocksViewsRouter: DocumentViewBaseCompoundRouter {
     
    // MARK: Subclassing
    override func match(action: BlocksViews.UserAction) -> DocumentViewBaseRouter? {
        switch action {
        case .specific(.page): return self.router(of: EmojiViewRouter.self)
        default: return nil
        }
    }
    
    override func defaultRouters() -> [DocumentViewBaseRouter] {
        [EmojiViewRouter()]
    }
}


// MARK: PageBlocksViewsRouter / EmojiRouter
extension PageBlocksViewsRouter {
    class EmojiViewRouter: DocumentViewBaseRouter {
        private func handle(action: BlocksViews.UserAction.Page.UserAction.EmojiAction) {
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

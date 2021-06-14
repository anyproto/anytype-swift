import UIKit
import Combine

final class DocumentViewCompoundRouter {
    private var userActionsStreamSubscription: AnyCancellable?
    
    private let fileRouter: FileRouter
    private let emojiRouter: EmojiViewRouter
    private let addBlockRouter: AddBlockToolbarRouter
    private let bookmarkRouter: BookmarkToolbarRouter
    private let turnIntoRouter: TurnIntoToolbarRouter
    
    init(
        viewController: UIViewController,
        userActionsStream: AnyPublisher<BlocksViews.UserAction, Never>
    ) {
        fileRouter = FileRouter(fileLoader: FileLoader(), viewController: viewController)
        emojiRouter = EmojiViewRouter(viewController: viewController)
        addBlockRouter = AddBlockToolbarRouter(baseViewController: viewController)
        bookmarkRouter = BookmarkToolbarRouter(vc: viewController)
        turnIntoRouter = TurnIntoToolbarRouter(baseViewController: viewController)
        
        userActionsStreamSubscription = userActionsStream.sink { [weak self] value in
            self?.receive(action: value)
        }
    }
    
    func receive(action: BlocksViews.UserAction) {
        switch action {
        case let .file(fileAction):
            fileRouter.handle(action: fileAction)
        case let .emoji(emojiModel):
            emojiRouter.handle(model: emojiModel)
        case let .addBlock(addBlock):
            addBlockRouter.handle(payload: addBlock)
        case let .bookmark(bookmark):
            bookmarkRouter.hanlde(bookmark: bookmark)
        case let .turnIntoBlock(payload):
            turnIntoRouter.handle(payload: payload)
        }
    }
}

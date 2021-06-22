import UIKit
import Combine

final class DocumentViewCompoundRouter {
    private var userActionsStreamSubscription: AnyCancellable?
    
    private let fileRouter: FileRouter
    private let bookmarkRouter: BookmarkToolbarRouter
    
    init(
        viewController: UIViewController,
        userActionsStream: AnyPublisher<BlockUserAction, Never>
    ) {
        fileRouter = FileRouter(fileLoader: FileLoader(), viewController: viewController)
        bookmarkRouter = BookmarkToolbarRouter(baseController: viewController)
        
        userActionsStreamSubscription = userActionsStream.sink { [weak self] value in
            self?.receive(action: value)
        }
    }
    
    func receive(action: BlockUserAction) {
        switch action {
        case let .file(fileAction):
            fileRouter.handle(action: fileAction)
        case let .bookmark(payload):
            bookmarkRouter.hanlde(bookmarkOutput: payload)
        }
    }
}

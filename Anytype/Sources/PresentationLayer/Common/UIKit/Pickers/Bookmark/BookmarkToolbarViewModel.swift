import SwiftUI
import Combine
import BlocksModels

final class BookmarkToolbarViewModel {
    let action: AnyPublisher<ActionPayload, Never>
    let dismissControllerPublisher: AnyPublisher<Void, Never>
    
    // MARK: Subscriptions
    private var subscriptions: Set<AnyCancellable> = []
            
    // MARK: Models
    @ObservedObject private var bookmarkViewModel: BlockToolbarBookmark.ViewModel
    
    private let model: BlockActiveRecordModelProtocol
    
    // MARK: Initialization
    init(model: BlockActiveRecordModelProtocol) {
        self.model = model
        let bookmarkViewModel = BlockToolbarBookmark.ViewModelBuilder.create()
        self.bookmarkViewModel = bookmarkViewModel
        
        self.action = bookmarkViewModel.userAction.map { value in
            ActionPayload.fetch(block: model, url: value)
        } .eraseToAnyPublisher()
        
        self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
    }
            
    // MARK: Get Chosen View
    func chosenView() -> StyleAndViewAndPayload {
        return StyleAndViewAndPayload(
            view: BlockToolbarBookmark.InputViewBuilder.createView(self._bookmarkViewModel),
            payload: .init(title: self.bookmarkViewModel.title)
        )
    }
}

// MARK: Subscriptions
// TODO: Move this method to protocol.
// Theoretically each class can get power of this method.
extension BookmarkToolbarViewModel {
    func subscribe<S, T>(subject: S, keyPath: KeyPath<BookmarkToolbarViewModel, T>) where T: Publisher, S: Subject, T.Output == S.Output, T.Failure == S.Failure {
        self[keyPath: keyPath].subscribe(subject).store(in: &self.subscriptions)
    }
}

// MARK: StyleAndViewAndPayload
extension BookmarkToolbarViewModel {
    struct StyleAndViewAndPayload {
        struct Payload {
            let title: String
        }
        let view: UIView?
        let payload: Payload?
    }
}

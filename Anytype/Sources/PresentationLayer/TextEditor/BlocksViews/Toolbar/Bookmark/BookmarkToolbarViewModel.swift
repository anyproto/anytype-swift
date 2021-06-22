import SwiftUI
import Combine

final class BookmarkToolbarViewModel {
    // MARK: Variables
    var action: AnyPublisher<BlockToolbarAction, Never> = .empty()
    var dismissControllerPublisher: AnyPublisher<Void, Never> = .empty()
    
    // MARK: Subscriptions
    private var subscriptions: Set<AnyCancellable> = []
            
    // MARK: Models
    @ObservedObject private var bookmarkViewModel: BlockToolbarBookmark.ViewModel
    
    // MARK: Setup
    private func publisher() -> AnyPublisher<BlockToolbarAction, Never> {
        return self.bookmarkViewModel.userAction.map({ value in
            BlockToolbarAction.bookmark(.fetch(value))
        }).eraseToAnyPublisher()
    }
    private func setup() {
        self.action = self.publisher()
        self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    init() {
        self.bookmarkViewModel = BlockToolbarBookmark.ViewModelBuilder.create()
        
        self.setup()
    }
            
    // MARK: Get Chosen View
    func chosenView() -> StyleAndViewAndPayload {
        return .init(
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

import SwiftUI
import Combine
import BlocksModels

final class BookmarkToolbarViewModel {
    private weak var actionHandler: NewBlockActionHandler?
    weak var controller: BookmarkViewController!
    
    // MARK: Subscriptions
    private var subscription: AnyCancellable?
            
    // MARK: Models
    @ObservedObject private var bookmarkViewModel: BlockToolbarBookmark.ViewModel
    
    private let model: BlockActiveRecordModelProtocol
    private let completion: (URL) -> ()
    
    // MARK: Initialization
    init(
        model: BlockActiveRecordModelProtocol,
        completion: @escaping (URL) -> ()
    ) {
        self.model = model
        let bookmarkViewModel = BlockToolbarBookmark.ViewModelBuilder.create()
        self.bookmarkViewModel = bookmarkViewModel
        self.completion = completion
        
        subscription = bookmarkViewModel.userAction.sink { [weak self] url in
            self?.controller?.dismiss(animated: true, completion: nil)
            completion(url)
        }
    }
            
    // MARK: Get Chosen View
    func chosenView() -> StyleAndViewAndPayload {
        return StyleAndViewAndPayload(
            view: BlockToolbarBookmark.InputViewBuilder.createView(self._bookmarkViewModel),
            payload: .init(title: self.bookmarkViewModel.title)
        )
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

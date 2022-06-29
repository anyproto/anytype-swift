import BlocksModels
import AnytypeCore

final class CreateBookmarkViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.bookmark
    
    private let bookmarkService: BookmarkServiceProtocol
    private let closeAction: () -> Void
    private var currentText: String = .empty

    init(bookmarkService: BookmarkServiceProtocol,
         closeAction: @escaping () -> Void) {
        self.bookmarkService = bookmarkService
        self.closeAction = closeAction
    }
    
    func textDidChange(_ text: String) {
        currentText = text
    }

    func actionButtonTapped(with text: String) {
        guard text.isNotEmpty else { return }
        bookmarkService.createBookmarkObject(url: text)
        closeAction()
    }

    func returnDidTap() {
        guard currentText.isNotEmpty else { return }
        bookmarkService.createBookmarkObject(url: currentText)
        closeAction()
    }
}

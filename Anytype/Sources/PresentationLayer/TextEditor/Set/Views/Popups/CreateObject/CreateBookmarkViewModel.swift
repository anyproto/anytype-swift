import Services
import AnytypeCore

final class CreateBookmarkViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.bookmark
    
    private let bookmarkService: BookmarkServiceProtocol
    private let closeAction: (_ details: ObjectDetails?) -> Void
    private var currentText: String = .empty

    init(bookmarkService: BookmarkServiceProtocol, closeAction: @escaping (_ details: ObjectDetails?) -> Void) {
        self.bookmarkService = bookmarkService
        self.closeAction = closeAction
    }
    
    func textDidChange(_ text: String) {
        currentText = text
    }

    func actionButtonTapped(with text: String) {
        guard text.isNotEmpty else { return }
        createBookmarkObject(with: text)
    }

    func returnDidTap() {
        guard currentText.isNotEmpty else { return }
        createBookmarkObject(with: currentText)
    }
    
    private func createBookmarkObject(with url: String) {
        Task { @MainActor in
            do {
                let details = try await bookmarkService.createBookmarkObject(url: currentText)
                closeAction(details)
            } catch {
                closeAction(nil)
            }
        }
    }
}

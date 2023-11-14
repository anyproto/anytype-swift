import Services
import AnytypeCore

final class CreateBookmarkViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.bookmark
    
    private let spaceId: String
    private let collectionId: String?
    private let bookmarkService: BookmarkServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let closeAction: (_ details: ObjectDetails?) -> Void
    private var currentText: String = .empty

    init(
        spaceId: String,
        collectionId: String?,
        bookmarkService: BookmarkServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        closeAction: @escaping (_ details: ObjectDetails?) -> Void
    ) {
        self.spaceId = spaceId
        self.collectionId = collectionId
        self.bookmarkService = bookmarkService
        self.objectActionsService = objectActionsService
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
                let details = try await bookmarkService.createBookmarkObject(spaceId: spaceId, url: currentText, origin: .none)
                addObjectToCollectionIfNeeded(details)
                closeAction(details)
                
                AnytypeAnalytics.instance().logCreateObject(
                    objectType: details.analyticsType,
                    route: collectionId.isNotNil ? .collection : .set
                )
            } catch {
                closeAction(nil)
            }
        }
    }
    
    private func addObjectToCollectionIfNeeded(_ details: ObjectDetails) {
        guard let collectionId else { return }
        Task {
            try await objectActionsService.addObjectsToCollection(
                contextId: collectionId,
                objectIds: [details.id]
            )
        }
    }
}

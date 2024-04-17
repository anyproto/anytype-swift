import Services
import AnytypeCore

final class CreateBookmarkViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.bookmark
    
    private let spaceId: String
    private let collectionId: String?
    private let bookmarkService: BookmarkServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let closeAction: (_ details: ObjectDetails?) -> Void
    private var currentText: String = ""

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
        guard let url = AnytypeURL(string: text) else { return }
        createBookmarkObject(with: url)
    }

    func returnDidTap() {
        guard currentText.isNotEmpty else { return }
        guard let url = AnytypeURL(string: currentText) else { return }
        createBookmarkObject(with: url)
    }
    
    private func createBookmarkObject(with url: AnytypeURL) {
        Task { @MainActor in
            do {
                let details = try await bookmarkService.createBookmarkObject(spaceId: spaceId, url: url, origin: .none)
                addObjectToCollectionIfNeeded(details)
                closeAction(details)
                
                AnytypeAnalytics.instance().logCreateObject(
                    objectType: details.analyticsType,
                    spaceId: details.spaceId,
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

import Foundation

public protocol BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String)
    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    )
    func createBookmarkObject(url: String) throws -> ObjectDetails
    func fetchBookmarkContent(bookmarkId: BlockId, url: String)
}

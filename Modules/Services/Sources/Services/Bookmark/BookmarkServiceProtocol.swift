import Foundation

public protocol BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) async throws
    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    ) async throws
    func createBookmarkObject(spaceId: String, url: String) async throws -> ObjectDetails
    func fetchBookmarkContent(bookmarkId: BlockId, url: String) async throws
}

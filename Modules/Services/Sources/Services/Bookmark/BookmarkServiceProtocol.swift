import Foundation

public protocol BookmarkServiceProtocol {
    func fetchBookmark(contextID: String, blockID: String, url: String) async throws
    func createAndFetchBookmark(
        contextID: String,
        targetID: String,
        position: BlockPosition,
        url: String
    ) async throws
    func createBookmarkObject(
        spaceId: String,
        url: String,
        origin: ObjectOrigin
    ) async throws -> ObjectDetails
    func fetchBookmarkContent(bookmarkId: String, url: String) async throws
}

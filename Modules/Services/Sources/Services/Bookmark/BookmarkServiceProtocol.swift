import Foundation

public protocol BookmarkServiceProtocol {
    func fetchBookmark(objectId: String, blockID: String, url: String) async throws
    func createAndFetchBookmark(
        objectId: String,
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

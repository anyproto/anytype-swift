import Foundation
import AnytypeCore


public protocol BookmarkServiceProtocol {
    func fetchBookmark(objectId: String, blockID: String, url: AnytypeURL) async throws
    func createAndFetchBookmark(
        objectId: String,
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) async throws
    func createBookmarkObject(
        spaceId: String,
        url: AnytypeURL,
        origin: ObjectOrigin
    ) async throws -> ObjectDetails
    func fetchBookmarkContent(bookmarkId: String, url: AnytypeURL) async throws
}

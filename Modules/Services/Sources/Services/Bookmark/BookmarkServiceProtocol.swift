import Foundation
import AnytypeCore


public protocol BookmarkServiceProtocol: Sendable {
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
        templateId: String?,
        origin: ObjectOrigin,
        createdInContext: String,
        createdInContextRef: String
    ) async throws -> ObjectDetails
    func fetchBookmarkContent(bookmarkId: String, url: AnytypeURL) async throws
    func fetchLinkPreview(url: AnytypeURL) async throws -> LinkPreview
}

public extension BookmarkServiceProtocol {
    func createBookmarkObject(
        spaceId: String,
        url: AnytypeURL,
        templateId: String?,
        origin: ObjectOrigin
    ) async throws -> ObjectDetails {
        try await createBookmarkObject(
            spaceId: spaceId,
            url: url,
            templateId: templateId,
            origin: origin,
            createdInContext: "",
            createdInContextRef: ""
        )
    }
}

import ProtobufMessages
import SwiftProtobuf

public final class BookmarkService: BookmarkServiceProtocol {
    
    public init() {}
    
    public func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) async throws {
        _ = try await ClientCommands.blockBookmarkFetch(.with {
            $0.contextID = contextID
            $0.blockID = blockID
            $0.url = url
        }).invoke()
    }

    public func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    ) async throws {
        try await ClientCommands.blockBookmarkCreateAndFetch(.with {
            $0.contextID = contextID
            $0.targetID = targetID
            $0.position = position.asMiddleware
            $0.url = url
        }).invoke()
    }
    
    public func createBookmarkObject(spaceId: String, url: String) async throws -> ObjectDetails {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.source.rawValue: url.protobufValue
            ]
        )
        let result = try await ClientCommands.objectCreateBookmark(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        return try result.details.toDetails()
    }
    
    public func fetchBookmarkContent(bookmarkId: BlockId, url: String) async throws {
        try await ClientCommands.objectBookmarkFetch(.with {
            $0.contextID = bookmarkId
            $0.url = url
        }).invoke()
    }
}

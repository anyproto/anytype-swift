import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

final class BookmarkService: BookmarkServiceProtocol {
    
    public func fetchBookmark(objectId: String, blockID: String, url: AnytypeURL) async throws {
        _ = try await ClientCommands.blockBookmarkFetch(.with {
            $0.contextID = objectId
            $0.blockID = blockID
            $0.url = url.absoluteString
        }).invoke()
    }

    public func createAndFetchBookmark(
        objectId: String,
        targetID: String,
        position: BlockPosition,
        url: AnytypeURL
    ) async throws {
        try await ClientCommands.blockBookmarkCreateAndFetch(.with {
            $0.contextID = objectId
            $0.targetID = targetID
            $0.position = position.asMiddleware
            $0.url = url.absoluteString
        }).invoke()
    }
    
    public func createBookmarkObject(
        spaceId: String,
        url: AnytypeURL,
        templateId: String?,
        origin: ObjectOrigin
    ) async throws -> ObjectDetails {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.source.rawValue: url.absoluteString.protobufValue,
                BundledRelationKey.origin.rawValue: origin.rawValue.protobufValue
            ]
        )
        let result = try await ClientCommands.objectCreateBookmark(.with {
            $0.details = details
            $0.spaceID = spaceId
            $0.templateID = templateId ?? ""
        }).invoke()
        return try result.details.toDetails()
    }
    
    public func fetchBookmarkContent(bookmarkId: String, url: AnytypeURL) async throws {
        try await ClientCommands.objectBookmarkFetch(.with {
            $0.contextID = bookmarkId
            $0.url = url.absoluteString
        }).invoke()
    }
    
    func fetchLinkPreview(url: AnytypeURL) async throws -> LinkPreview {
        let result = try await ClientCommands.linkPreview(.with {
            $0.url = url.absoluteString
        }).invoke()
        return result.linkPreview
    }
}

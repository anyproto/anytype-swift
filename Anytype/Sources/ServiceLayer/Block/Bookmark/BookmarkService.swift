import ProtobufMessages
import Services
import SwiftProtobuf

class BookmarkService: BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) {
        _ = try? ClientCommands.blockBookmarkFetch(.with {
            $0.contextID = contextID
            $0.blockID = blockID
            $0.url = url
        }).invoke()
    }

    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    ) {
        _ = try? ClientCommands.blockBookmarkCreateAndFetch(.with {
            $0.contextID = contextID
            $0.targetID = targetID
            $0.position = position.asMiddleware
            $0.url = url
        }).invoke()
    }
    
    func createBookmarkObject(url: String) -> Bool {
        
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.source.rawValue: url.protobufValue
            ]
        )
        
        let result = try? ClientCommands.objectCreateBookmark(.with {
            $0.details = details
        }).invoke()
        return result.isNotNil
    }
    
    func fetchBookmarkContent(bookmarkId: BlockId, url: String) {
        _ = try? ClientCommands.objectBookmarkFetch(.with {
            $0.contextID = bookmarkId
            $0.url = url
        }).invoke()
    }
}

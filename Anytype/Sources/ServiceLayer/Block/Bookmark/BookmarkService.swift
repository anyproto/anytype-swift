import ProtobufMessages
import BlocksModels
import SwiftProtobuf

class BookmarkService: BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) {
        Anytype_Rpc.BlockBookmark.Fetch.Service
            .invoke(contextID: contextID, blockID: blockID, url: url)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .bookmarkService)?
            .send()
    }

    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    ) {
        Anytype_Rpc.BlockBookmark.CreateAndFetch.Service
            .invoke(
                contextID: contextID,
                targetID: targetID,
                position: position.asMiddleware,
                url: url
            )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .bookmarkService)?
            .send()
    }
    
    func createBookmarkObject(url: String, completion: @escaping (_ withError: Bool) -> Void) {
        
        #warning("Use key from constants")
        let details = Google_Protobuf_Struct(
            fields: [
                "source": url.protobufValue
            ]
        )
        
        let result = Anytype_Rpc.Object.CreateBookmark.Service.invocation(details: details)
            .invoke()
            .getValue(domain: .bookmarkService)

        completion(result == nil)
    }
    
    func fetchBookmarkContent(bookmarkId: BlockId, url: String) {
        _ = Anytype_Rpc.Object.BookmarkFetch.Service.invocation(contextID: bookmarkId, url: url).invoke()
    }
}

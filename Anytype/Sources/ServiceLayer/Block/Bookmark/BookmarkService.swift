import ProtobufMessages
import BlocksModels

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
}

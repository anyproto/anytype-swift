import ProtobufMessages
import BlocksModels

class BookmarkService: BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) {
        Anytype_Rpc.Block.Bookmark.Fetch.Service
            .invoke(contextID: contextID, blockID: blockID, url: url)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .bookmarkService)?
            .send()
    }
}

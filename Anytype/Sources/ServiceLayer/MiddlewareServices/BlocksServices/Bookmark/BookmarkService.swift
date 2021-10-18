import ProtobufMessages
import BlocksModels

class BookmarkService: BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) -> MiddlewareResponse? {
        Anytype_Rpc.Block.Bookmark.Fetch.Service.invoke(contextID: contextID, blockID: blockID, url: url)
            .map { MiddlewareResponse($0.event) }
            .getValue()
    }
}

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
    
    func createBookmarkObject(url: String, completion: @escaping (_ withError: Bool) -> Void) {
        let result = Anytype_Rpc.Object.CreateBookmark.Service.invoke(url: url)
        switch result {
        case .success(let response):
            let error = response.error
            switch error.code {
            case .null:
                completion(false)
            case .unknownError, .badInput, .UNRECOGNIZED:
                completion(true)
            }
        case .failure:
            completion(true)
        }
    }
}

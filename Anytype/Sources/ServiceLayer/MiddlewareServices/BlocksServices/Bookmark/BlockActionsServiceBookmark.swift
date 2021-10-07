import Foundation
import BlocksModels
import Combine
import ProtobufMessages
import BlocksModels

/// Concrete service that adopts BookmarkBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
class BlockActionsServiceBookmark: BlockActionsServiceBookmarkProtocol {
    var fetchBookmark: FetchBookmark = .init()
}

// MARK: - BookmarkActionsService / Actions
extension BlockActionsServiceBookmark {
    /// Structure that adopts `FetchBookmark` action protocol
    struct FetchBookmark: BlockActionsServiceBookmarkProtocolFetchBookmark {
        typealias Success = ResponseEvent
        func action(contextID: BlockId, blockID: BlockId, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.Fetch.Service.invoke(contextID: contextID, blockID: blockID, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    /// Structure that adopts `CreateAndFetchBookmark` action protocol
    struct CreateAndFetchBookmark: BlockActionsServiceBookmarkProtocolCreateAndFetchBookmark {
        typealias Success = ResponseEvent
        func action(contextID: BlockId, targetID: BlockId, position: BlockPosition, url: String) -> AnyPublisher<ResponseEvent, Error> {
            action(contextID: contextID, targetID: targetID, position: position.asMiddleware, url: url)
        }
        private func action(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.CreateAndFetch.Service.invoke(contextID: contextID, targetID: targetID, position: position, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

import Foundation
import Combine
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for fetch bookmark.
protocol BlockActionsServiceBookmarkProtocolFetchBookmark {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId, url: String) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceBookmarkProtocolCreateAndFetchBookmark {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Position = TopLevel.AliasesMap.Position
    func action(contextID: BlockId, targetID: BlockId, position: Position, url: String) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Bookmark actions services.
protocol BlockActionsServiceBookmarkProtocol {
    associatedtype FetchBookmark: BlockActionsServiceBookmarkProtocolFetchBookmark
    var fetchBookmark: FetchBookmark {get}
}

import Foundation
import Combine
import BlocksModels

protocol BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String) -> ResponseEvent?
}

import Foundation
import Combine
import Services

protocol BookmarkServiceProtocol {
    func fetchBookmark(contextID: BlockId, blockID: BlockId, url: String)
    func createAndFetchBookmark(
        contextID: BlockId,
        targetID: BlockId,
        position: BlockPosition,
        url: String
    )
    func createBookmarkObject(url: String) -> Bool
    func fetchBookmarkContent(bookmarkId: BlockId, url: String)
}

import Foundation
import BlocksModels

struct TableOfContentItem: Equatable, Hashable {
    let blockId: BlockId
    let title: String
    let level: Int
}

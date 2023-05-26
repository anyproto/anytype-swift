import Foundation
import Services

enum TableOfContentData: Equatable {
    case items([TableOfContentItem])
    case empty(String)
}

struct TableOfContentItem: Equatable, Hashable {
    let blockId: BlockId
    let title: String
    let level: Int
}

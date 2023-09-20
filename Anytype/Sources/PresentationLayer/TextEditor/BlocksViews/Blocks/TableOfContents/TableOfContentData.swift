import Foundation
import Services

enum TableOfContentData: Equatable {
    case items([TableOfContentItem])
    case empty(String)
}

final class TableOfContentItem: Equatable, Hashable, ObservableObject {
    let blockId: BlockId
    @Published var title: String
    let level: Int
    
    deinit {
        print("TableOfContentItem deinited")
    }
    
    init(blockId: BlockId, title: String, level: Int) {
        self.blockId = blockId
        self.title = title
        self.level = level
    }
    
    static func == (lhs: TableOfContentItem, rhs: TableOfContentItem) -> Bool {
        lhs.blockId == rhs.blockId && lhs.title == rhs.title && lhs.level == rhs.level
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(blockId)
        hasher.combine(title)
        hasher.combine(level)
    }
}

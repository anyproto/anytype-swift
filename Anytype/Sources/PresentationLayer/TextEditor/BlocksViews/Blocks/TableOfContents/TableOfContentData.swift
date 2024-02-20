import Foundation
import Services

enum TableOfContentData: Equatable {
    case items([TableOfContentItem])
    case empty(String)
}

final class TableOfContentItem: Equatable, Hashable, ObservableObject {
    let blockId: String
    @Published var title: String
    let level: Int
    
    init(blockId: String, title: String, level: Int) {
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

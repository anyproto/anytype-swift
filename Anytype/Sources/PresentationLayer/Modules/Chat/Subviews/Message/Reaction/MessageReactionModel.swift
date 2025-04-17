import Foundation

struct MessageReactionModel: Equatable, Hashable {
    var emoji: String
    var content: MessageReactionModelContent
    var selected: Bool
    var position: MessageHorizontalPosition
}

enum MessageReactionModelContent: Equatable, Hashable {
    case count(Int)
    case icon(Icon)
    
    var sortWeight: Int {
        switch self {
        case .count(let count):
            return count
        case .icon:
            return 1
        }
    }
}

import Foundation
import UIKit

struct MessageReactionData: Equatable, Hashable {
    let emoji: String
    let content: MessageReactionModelContent
    let selected: Bool
    let position: MessageHorizontalPosition
    let messageYourBackgroundColor: UIColor
    
    var emojiAttributedString: NSAttributedString {
        NSAttributedString(
            string: emoji,
            // Don't needed anytype style because emojy font will be replace to system
            attributes: [.font: UIFont.systemFont(ofSize: 14)]
        )
    }
    
    var countAttributedString: NSAttributedString? {
        switch content {
        case .count(let count):
            return NSAttributedString(
                string: "\(count)",
                attributes: [.font: UIFont.caption1Regular]
            )
        case .icon(let icon):
            return nil
        }
    }
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

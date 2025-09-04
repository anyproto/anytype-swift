import Foundation
import UIKit

struct MessageReactionListData: Equatable, Hashable {
    let reactions: [MessageReactionData]
    let canAddReaction: Bool
    let position: MessageHorizontalPosition
}

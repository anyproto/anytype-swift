import Foundation
import UIKit
import StoredHashMacro

@StoredHash
struct MessageReactionListData: Equatable, Hashable {
    let reactions: [MessageReactionData]
    let canAddReaction: Bool
    let position: MessageHorizontalPosition
}

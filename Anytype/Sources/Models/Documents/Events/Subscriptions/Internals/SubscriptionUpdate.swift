import Foundation
import Services

enum SubscriptionUpdate {
    case remove(BlockId)
    case add(BlockId, after: BlockId?)
    case move(from: BlockId, after: BlockId?)
}

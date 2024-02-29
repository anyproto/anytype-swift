import Foundation
import Services

enum SubscriptionUpdate {
    case remove(String)
    case add(String, after: String?)
    case move(from: String, after: String?)
}

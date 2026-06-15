import Foundation
import Services

struct SubscriptionStorageState: Equatable, Sendable {
    var total: Int
    var nextCount: Int
    var prevCount: Int
    var items: [ObjectDetails]
}

import Foundation
import Services

@MainActor
protocol SetSubscriptionDataBuilderProtocol: AnyObject {
    func set(_ data: SetSubscriptionData) -> SubscriptionData
}

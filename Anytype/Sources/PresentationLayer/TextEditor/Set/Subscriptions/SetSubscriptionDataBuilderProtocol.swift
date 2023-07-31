import Foundation
import Services

protocol SetSubscriptionDataBuilderProtocol: AnyObject {
    func set(_ data: SetSubscriptionData) -> SubscriptionData
}

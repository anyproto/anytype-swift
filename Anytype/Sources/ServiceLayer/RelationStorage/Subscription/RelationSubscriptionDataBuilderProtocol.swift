import Foundation
import Services

protocol RelationSubscriptionDataBuilderProtocol: AnyObject {
    func build(spaceId: String, subId: String) -> SubscriptionData
}

import Foundation
import Services

protocol RelationSubscriptionDataBuilderProtocol: AnyObject {
    func build() -> SubscriptionData
}

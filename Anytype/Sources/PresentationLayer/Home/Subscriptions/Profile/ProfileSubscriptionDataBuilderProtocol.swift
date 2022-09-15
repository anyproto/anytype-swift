import Foundation

protocol ProfileSubscriptionDataBuilderProtocol: AnyObject {
    func profile(id: String) -> SubscriptionData
}

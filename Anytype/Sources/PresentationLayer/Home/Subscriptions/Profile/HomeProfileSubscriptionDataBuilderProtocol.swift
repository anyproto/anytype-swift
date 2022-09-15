import Foundation

protocol HomeProfileSubscriptionDataBuilderProtocol: AnyObject {
    func profile(id: String) -> SubscriptionData
}

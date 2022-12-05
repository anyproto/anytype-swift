import Foundation

protocol TabsSubscriptionDataBuilderProtocol: AnyObject {
    func allIds() -> [SubscriptionId]
    func build(for tab: HomeTabsView.Tab) -> SubscriptionData
}

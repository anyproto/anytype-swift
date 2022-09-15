import Foundation

protocol TabsSubscriptionDataBuilderProtocol: AnyObject {
    func build(for tab: HomeTabsView.Tab) -> SubscriptionData?
}

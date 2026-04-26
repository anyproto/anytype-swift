import Foundation
import Services
import AsyncTools

protocol ObjectsWithUnreadDiscussionsSubscriptionNewProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscription() async
}

actor ObjectsWithUnreadDiscussionsSubscriptionNew: ObjectsWithUnreadDiscussionsSubscriptionNewProtocol {

    private let primarySubId = "SubscriptionId.ObjectsWithUnreadDiscussions"

    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let primaryStorage: any SubscriptionStorageProtocol

    init() {
        self.primaryStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: primarySubId)
    }

    func startSubscription() async {
        try? await primaryStorage.startOrUpdateSubscription(data: buildSubscriptionData()) { state in
            debugPrint("[unread-new] items=\(state.items.count)")
            for item in state.items {
                debugPrint("[unread-new] unreadMessageCount=\(item.unreadMessageCount), unreadMentionCount=\(item.unreadMentionCount)")
            }
        }
    }

    func stopSubscription() async {
        try? await primaryStorage.stopSubscription()
    }

    private func buildSubscriptionData() -> SubscriptionData {
        let filters: [DataviewFilter] = [
            SearchHelper.layoutFilter(DetailsLayout.editorLayouts + DetailsLayout.listLayouts),
            unreadCountersFilter()
        ]
        let keys: [String] = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.layout.rawValue,
            BundledPropertyKey.backlinks.rawValue,
            BundledPropertyKey.lastMessageDate.rawValue,
            BundledPropertyKey.notificationSubscribers.rawValue,
            BundledPropertyKey.unreadMessageCount.rawValue,
            BundledPropertyKey.unreadMentionCount.rawValue
        ]
        return .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: primarySubId,
                filters: filters,
                keys: keys,
                noDepSubscription: true
            )
        )
    }

    private func unreadCountersFilter() -> DataviewFilter {
        var visibility = DataviewFilter()
        visibility.operator = .or
        visibility.nestedFilters = [
            countGreaterThanZero(relation: .unreadMessageCount),
            countGreaterThanZero(relation: .unreadMentionCount)
        ]
        return visibility
    }

    private func countGreaterThanZero(relation: BundledPropertyKey) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .greater
        filter.relationKey = relation.rawValue
        filter.value = 0.protobufValue
        return filter
    }
}

extension Container {
    var objectsWithUnreadDiscussionsSubscriptionNew: Factory<any ObjectsWithUnreadDiscussionsSubscriptionNewProtocol> {
        self { ObjectsWithUnreadDiscussionsSubscriptionNew() }.singleton
    }
}

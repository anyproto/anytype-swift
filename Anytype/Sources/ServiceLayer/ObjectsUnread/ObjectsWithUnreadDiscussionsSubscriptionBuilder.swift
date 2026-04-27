import Foundation
import Services

protocol ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build() -> SubscriptionData
}

final class ObjectsWithUnreadDiscussionsSubscriptionBuilder: ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol {

    private enum Constants {
        static let subId = "SubscriptionId.ObjectsWithUnreadDiscussions"
    }

    var subscriptionId: String { Constants.subId }

    func build() -> SubscriptionData {
        // A mention message is also a regular message, so any parent with unread mentions
        // also has `unreadMessageCount > 0`. Filtering on the message count alone is sufficient.
        let parentBranch = andFilter([
            SearchHelper.layoutFilter(DetailsLayout.supportedForDiscussion),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.isHidden(false),
            countGreaterThanZero(relation: .unreadMessageCount)
        ])
        let discussionBranch = SearchHelper.layoutFilter([.discussion])
        let filters: [DataviewFilter] = [
            orFilter([parentBranch, discussionBranch])
        ]
        let keys: [String] = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.resolvedLayout.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.snippet.rawValue,
            BundledPropertyKey.discussionId.rawValue,
            BundledPropertyKey.lastMessageDate.rawValue,
            BundledPropertyKey.notificationSubscribers.rawValue,
            BundledPropertyKey.unreadMessageCount.rawValue,
            BundledPropertyKey.unreadMentionCount.rawValue
        ]
        return .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: Constants.subId,
                filters: filters,
                keys: keys,
                noDepSubscription: true
            )
        )
    }

    // MARK: - Filter helpers

    private func andFilter(_ filters: [DataviewFilter]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.operator = .and
        filter.nestedFilters = filters
        return filter
    }

    private func orFilter(_ filters: [DataviewFilter]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.operator = .or
        filter.nestedFilters = filters
        return filter
    }

    private func countGreaterThanZero(relation: BundledPropertyKey) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .greater
        filter.relationKey = relation.rawValue
        filter.value = 0.protobufValue
        return filter
    }
}

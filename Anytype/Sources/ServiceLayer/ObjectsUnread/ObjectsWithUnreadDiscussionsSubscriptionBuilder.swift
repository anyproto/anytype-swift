import Foundation
import Services

protocol ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol: AnyObject, Sendable {
    var subscriptionId: String { get }
    func build(myParticipantIds: [String]) -> SubscriptionData
}

final class ObjectsWithUnreadDiscussionsSubscriptionBuilder: ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol {

    private enum Constants {
        static let subId = "SubscriptionId.ObjectsWithUnreadDiscussions"
    }

    var subscriptionId: String { Constants.subId }

    func build(myParticipantIds: [String]) -> SubscriptionData {
        let parentBranch = andFilter([
            SearchHelper.layoutFilter(DetailsLayout.editorLayouts + DetailsLayout.listLayouts),
            orFilter([
                countGreaterThanZero(relation: .unreadMessageCount),
                countGreaterThanZero(relation: .unreadMentionCount)
            ])
        ])
        let discussionBranch = andFilter([
            SearchHelper.layoutFilter([.discussion]),
            isInFilter(relation: .notificationSubscribers, values: myParticipantIds)
        ])
        let filters: [DataviewFilter] = [
            orFilter([parentBranch, discussionBranch])
        ]
        let keys: [String] = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.resolvedLayout.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.discussionId.rawValue,
            BundledPropertyKey.lastMessageDate.rawValue,
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

    private func isInFilter(relation: BundledPropertyKey, values: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.relationKey = relation.rawValue
        filter.value = values.protobufValue
        return filter
    }
}

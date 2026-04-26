import Foundation
import Services
import AnytypeCore

protocol ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol: AnyObject, Sendable {
    var primarySubscriptionId: String { get }
    var secondarySubscriptionId: String { get }
    func build(myParticipantIds: [String]) -> SubscriptionData
    func buildSecondary(parentIds: [String]) -> SubscriptionData
}

final class ObjectsWithUnreadDiscussionsSubscriptionBuilder: ObjectsWithUnreadDiscussionsSubscriptionBuilderProtocol {

    private enum Constants {
        static let primarySubId = "SubscriptionId.ObjectsWithUnreadDiscussions"
        static let secondarySubId = "SubscriptionId.ObjectsWithUnreadDiscussions.Parents"
    }

    var primarySubscriptionId: String { Constants.primarySubId }
    var secondarySubscriptionId: String { Constants.secondarySubId }

    func build(myParticipantIds: [String]) -> SubscriptionData {
//        let filters: [DataviewFilter] = [
//            SearchHelper.layoutFilter([.discussion]),
//            visibilityFilter(myParticipantIds: myParticipantIds)
//        ]

        let filters: [DataviewFilter] = [
            SearchHelper.layoutFilter([.discussion])
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
                identifier: Constants.primarySubId,
                filters: filters,
                keys: keys,
                noDepSubscription: true
            )
        )
    }

    func buildSecondary(parentIds: [String]) -> SubscriptionData {
        let filters: [DataviewFilter] = [
            SearchHelper.includeIdsFilter(parentIds)
        ]

        let keys: [String] = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.iconImage.rawValue,
            BundledPropertyKey.layout.rawValue,
            BundledPropertyKey.discussionId.rawValue
        ]

        return .crossSpaceSearch(
            SubscriptionData.CrossSpaceSearch(
                identifier: Constants.secondarySubId,
                filters: filters,
                keys: keys,
                noDepSubscription: true
            )
        )
    }

    // MARK: - Private

    /// `unreadMentionCount > 0 OR (unreadMessageCount > 0 AND notificationSubscribers IN [myParticipantIds])`
    /// — discussions a row should appear for. Rows 3 and 7 of the truth table are filtered server-side.
    private func visibilityFilter(myParticipantIds: [String]) -> DataviewFilter {
        var unreadAndSubscribed = DataviewFilter()
        unreadAndSubscribed.operator = .and
        unreadAndSubscribed.nestedFilters = [
            countGreaterThanZero(relation: .unreadMessageCount),
            isInFilter(relation: .notificationSubscribers, values: myParticipantIds)
        ]

        var visibility = DataviewFilter()
        visibility.operator = .or
        visibility.nestedFilters = [
            countGreaterThanZero(relation: .unreadMentionCount),
            unreadAndSubscribed
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

    private func isInFilter(relation: BundledPropertyKey, values: [String]) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.relationKey = relation.rawValue
        filter.value = values.protobufValue
        return filter
    }
}

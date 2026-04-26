import Testing
import Foundation
@testable import Anytype
import Services
import ProtobufMessages

struct ObjectsWithUnreadDiscussionsSubscriptionBuilderTests {

    private let builder = ObjectsWithUnreadDiscussionsSubscriptionBuilder()

    // MARK: - Identity

    @Test func subscriptionIds_areStableAndDistinct() {
        #expect(builder.primarySubscriptionId == "SubscriptionId.ObjectsWithUnreadDiscussions")
        #expect(builder.secondarySubscriptionId == "SubscriptionId.ObjectsWithUnreadDiscussions.Parents")
        #expect(builder.primarySubscriptionId != builder.secondarySubscriptionId)
    }

    // MARK: - Primary subscription

    @Test func primary_identifierMatchesSubscriptionId() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["me"]))
        #expect(crossSearch?.identifier == builder.primarySubscriptionId)
        #expect(crossSearch?.noDepSubscription == true)
    }

    @Test func primary_filtersByDiscussionLayoutAndNestedVisibility() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["me"]))
        let filters = crossSearch?.filters ?? []

        #expect(filters.count == 2)

        // Filter 1: layout IN [.discussion]
        #expect(filters[0].relationKey == BundledPropertyKey.resolvedLayout.rawValue)
        #expect(filters[0].condition == .in)

        // Filter 2: nested OR
        let visibility = filters[1]
        #expect(visibility.operator == .or)
        #expect(visibility.nestedFilters.count == 2)

        // OR branch 1: unreadMentionCount > 0
        let mentionBranch = visibility.nestedFilters[0]
        #expect(mentionBranch.relationKey == BundledPropertyKey.unreadMentionCount.rawValue)
        #expect(mentionBranch.condition == .greater)

        // OR branch 2: AND of (unreadMessageCount > 0, notificationSubscribers IN [...])
        let subscribedBranch = visibility.nestedFilters[1]
        #expect(subscribedBranch.operator == .and)
        #expect(subscribedBranch.nestedFilters.count == 2)
        #expect(subscribedBranch.nestedFilters[0].relationKey == BundledPropertyKey.unreadMessageCount.rawValue)
        #expect(subscribedBranch.nestedFilters[0].condition == .greater)
        #expect(subscribedBranch.nestedFilters[1].relationKey == BundledPropertyKey.notificationSubscribers.rawValue)
        #expect(subscribedBranch.nestedFilters[1].condition == .in)
    }

    @Test func primary_passesParticipantIdsIntoSubscribersFilter() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["alice", "bob"]))
        let subscribersFilter = crossSearch?.filters[1].nestedFilters[1].nestedFilters[1]
        let listValues = subscribersFilter?.value.listValue.values.map(\.stringValue)

        #expect(listValues == ["alice", "bob"])
    }

    @Test func primary_emptyParticipantIds_buildsValidFilter() {
        let crossSearch = unwrap(builder.build(myParticipantIds: []))
        let subscribersFilter = crossSearch?.filters[1].nestedFilters[1].nestedFilters[1]
        let listValues = subscribersFilter?.value.listValue.values.map(\.stringValue)

        #expect(listValues == [])
    }

    @Test func primary_includesAllConsumerKeys() {
        let crossSearch = unwrap(builder.build(myParticipantIds: []))
        let keys = Set(crossSearch?.keys ?? [])
        let expected: Set<String> = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.layout.rawValue,
            BundledPropertyKey.backlinks.rawValue,
            BundledPropertyKey.lastMessageDate.rawValue,
            BundledPropertyKey.notificationSubscribers.rawValue,
            BundledPropertyKey.unreadMessageCount.rawValue,
            BundledPropertyKey.unreadMentionCount.rawValue
        ]
        #expect(keys == expected)
    }

    // MARK: - Secondary subscription

    @Test func secondary_identifierMatchesSubscriptionId() {
        let crossSearch = unwrap(builder.buildSecondary(parentIds: ["parent-1"]))
        #expect(crossSearch?.identifier == builder.secondarySubscriptionId)
        #expect(crossSearch?.noDepSubscription == true)
    }

    @Test func secondary_filtersByIdInParentIds() {
        let crossSearch = unwrap(builder.buildSecondary(parentIds: ["a", "b"]))
        let filters = crossSearch?.filters ?? []

        #expect(filters.count == 1)
        #expect(filters[0].relationKey == BundledPropertyKey.id.rawValue)
        #expect(filters[0].condition == .in)

        let listValues = filters[0].value.listValue.values.map(\.stringValue)
        #expect(listValues == ["a", "b"])
    }

    @Test func secondary_includesAllConsumerKeys() {
        let crossSearch = unwrap(builder.buildSecondary(parentIds: []))
        let keys = Set(crossSearch?.keys ?? [])
        let expected: Set<String> = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.iconImage.rawValue,
            BundledPropertyKey.layout.rawValue,
            BundledPropertyKey.discussionId.rawValue
        ]
        #expect(keys == expected)
    }

    // MARK: - Helper

    private func unwrap(_ data: SubscriptionData) -> SubscriptionData.CrossSpaceSearch? {
        if case .crossSpaceSearch(let cs) = data { return cs }
        return nil
    }
}

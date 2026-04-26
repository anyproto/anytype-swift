import Testing
import Foundation
@testable import Anytype
import Services
import ProtobufMessages

struct ObjectsWithUnreadDiscussionsSubscriptionBuilderTests {

    private let builder = ObjectsWithUnreadDiscussionsSubscriptionBuilder()

    // MARK: - Identity

    @Test func subscriptionId_isStable() {
        #expect(builder.subscriptionId == "SubscriptionId.ObjectsWithUnreadDiscussions")
    }

    @Test func build_identifierMatchesSubscriptionId() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["me"]))
        #expect(crossSearch?.identifier == builder.subscriptionId)
        #expect(crossSearch?.noDepSubscription == true)
    }

    // MARK: - Filter shape

    @Test func build_topLevelFilterIsOrOfTwoBranches() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["me"]))
        let filters = crossSearch?.filters ?? []

        #expect(filters.count == 1)
        #expect(filters[0].operator == .or)
        #expect(filters[0].nestedFilters.count == 2)
    }

    @Test func build_parentBranch_filtersByLayoutsAndCounters() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["me"]))
        let parentBranch = crossSearch?.filters[0].nestedFilters[0]

        #expect(parentBranch?.operator == .and)
        #expect(parentBranch?.nestedFilters.count == 2)

        // Layout filter on editor + list layouts
        let layoutFilter = parentBranch?.nestedFilters[0]
        #expect(layoutFilter?.relationKey == BundledPropertyKey.resolvedLayout.rawValue)
        #expect(layoutFilter?.condition == .in)

        // Nested OR(unreadMessageCount > 0, unreadMentionCount > 0)
        let countersFilter = parentBranch?.nestedFilters[1]
        #expect(countersFilter?.operator == .or)
        #expect(countersFilter?.nestedFilters.count == 2)
        #expect(countersFilter?.nestedFilters[0].relationKey == BundledPropertyKey.unreadMessageCount.rawValue)
        #expect(countersFilter?.nestedFilters[0].condition == .greater)
        #expect(countersFilter?.nestedFilters[1].relationKey == BundledPropertyKey.unreadMentionCount.rawValue)
        #expect(countersFilter?.nestedFilters[1].condition == .greater)
    }

    @Test func build_discussionBranch_filtersByLayoutAndSubscribers() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["me"]))
        let discussionBranch = crossSearch?.filters[0].nestedFilters[1]

        #expect(discussionBranch?.operator == .and)
        #expect(discussionBranch?.nestedFilters.count == 2)

        // Layout filter on .discussion
        let layoutFilter = discussionBranch?.nestedFilters[0]
        #expect(layoutFilter?.relationKey == BundledPropertyKey.resolvedLayout.rawValue)
        #expect(layoutFilter?.condition == .in)

        // notificationSubscribers IN [...]
        let subscribersFilter = discussionBranch?.nestedFilters[1]
        #expect(subscribersFilter?.relationKey == BundledPropertyKey.notificationSubscribers.rawValue)
        #expect(subscribersFilter?.condition == .in)
    }

    @Test func build_passesParticipantIdsIntoSubscribersFilter() {
        let crossSearch = unwrap(builder.build(myParticipantIds: ["alice", "bob"]))
        let subscribersFilter = crossSearch?.filters[0].nestedFilters[1].nestedFilters[1]
        let listValues = subscribersFilter?.value.listValue.values.map(\.stringValue)

        #expect(listValues == ["alice", "bob"])
    }

    @Test func build_emptyParticipantIds_isValid() {
        let crossSearch = unwrap(builder.build(myParticipantIds: []))
        let subscribersFilter = crossSearch?.filters[0].nestedFilters[1].nestedFilters[1]
        let listValues = subscribersFilter?.value.listValue.values.map(\.stringValue)

        #expect(listValues == [])
    }

    // MARK: - Keys

    @Test func build_includesAllConsumerKeys() {
        let crossSearch = unwrap(builder.build(myParticipantIds: []))
        let keys = Set(crossSearch?.keys ?? [])
        let expected: Set<String> = [
            BundledPropertyKey.id.rawValue,
            BundledPropertyKey.spaceId.rawValue,
            BundledPropertyKey.resolvedLayout.rawValue,
            BundledPropertyKey.name.rawValue,
            BundledPropertyKey.discussionId.rawValue,
            BundledPropertyKey.lastMessageDate.rawValue,
            BundledPropertyKey.unreadMessageCount.rawValue,
            BundledPropertyKey.unreadMentionCount.rawValue
        ]
        #expect(keys == expected)
    }

    // MARK: - Helper

    private func unwrap(_ data: SubscriptionData) -> SubscriptionData.CrossSpaceSearch? {
        if case .crossSpaceSearch(let cs) = data { return cs }
        return nil
    }
}

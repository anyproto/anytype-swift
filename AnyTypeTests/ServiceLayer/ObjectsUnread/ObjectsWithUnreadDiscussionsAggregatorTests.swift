import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf

struct ObjectsWithUnreadDiscussionsAggregatorTests {

    private let me = "me"
    private let spaceA = "space-a"
    private let spaceB = "space-b"
    private let discussion1 = "discussion-1"
    private let discussion2 = "discussion-2"

    @Test func emptyItems_returnsEmptyDict() {
        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [], myParticipantIds: [me])
        #expect(result.isEmpty)
    }

    @Test func mentionOnlyParent_includedWithMentionContribution() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 7,
            unreadMentionCount: 2
        )

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent], myParticipantIds: [me])

        #expect(result[spaceA]?.unreadMessageCount == 0)
        #expect(result[spaceA]?.mentions.totalCount == 2)
    }

    @Test func subscribedParent_contributesMessagesAndMentions() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 5,
            unreadMentionCount: 1
        )
        let discussion = makeDiscussion(id: discussion1, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent, discussion], myParticipantIds: [me])

        #expect(result[spaceA]?.unreadMessageCount == 5)
        #expect(result[spaceA]?.mentions.totalCount == 1)
    }

    @Test func parentWithNoMentionAndNoSubscription_dropped() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 9,
            unreadMentionCount: 0
        )

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent], myParticipantIds: [me])

        #expect(result[spaceA] == nil)
    }

    @Test func discussionPresentButNotSubscribed_treatedAsUnsubscribed() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 5,
            unreadMentionCount: 2
        )
        let discussion = makeDiscussion(id: discussion1, subscribers: ["someone-else"])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent, discussion], myParticipantIds: [me])

        // Mention contributes; message count is dropped because I am not subscribed.
        #expect(result[spaceA]?.unreadMessageCount == 0)
        #expect(result[spaceA]?.mentions.totalCount == 2)
    }

    @Test func subscribedParentWithZeroCounters_keepsZeroContribution() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 0,
            unreadMentionCount: 0
        )
        let discussion = makeDiscussion(id: discussion1, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent, discussion], myParticipantIds: [me])

        #expect(result[spaceA]?.unreadMessageCount == 0)
        #expect(result[spaceA]?.mentions.totalCount == 0)
    }

    @Test func sumsAcrossParentsInSameSpace() {
        let parent1 = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 3,
            unreadMentionCount: 1
        )
        let parent2 = makeParent(
            id: "parent-2",
            spaceId: spaceA,
            discussionId: discussion2,
            unreadMessageCount: 4,
            unreadMentionCount: 2
        )
        let d1 = makeDiscussion(id: discussion1, subscribers: [me])
        let d2 = makeDiscussion(id: discussion2, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent1, parent2, d1, d2], myParticipantIds: [me])

        #expect(result[spaceA]?.unreadMessageCount == 7)
        #expect(result[spaceA]?.mentions.totalCount == 3)
    }

    @Test func groupsByDistinctSpaces() {
        let parentA = makeParent(
            id: "parent-a",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 3,
            unreadMentionCount: 0
        )
        let parentB = makeParent(
            id: "parent-b",
            spaceId: spaceB,
            discussionId: discussion2,
            unreadMessageCount: 5,
            unreadMentionCount: 1
        )
        let d1 = makeDiscussion(id: discussion1, subscribers: [me])
        let d2 = makeDiscussion(id: discussion2, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parentA, parentB, d1, d2], myParticipantIds: [me])

        #expect(result.count == 2)
        #expect(result[spaceA]?.unreadMessageCount == 3)
        #expect(result[spaceA]?.mentions.totalCount == 0)
        #expect(result[spaceB]?.unreadMessageCount == 5)
        #expect(result[spaceB]?.mentions.totalCount == 1)
    }

    @Test func mentionOnlyParent_excludesMessageCountFromUnsubscribed() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 8,
            unreadMentionCount: 3
        )

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent], myParticipantIds: [me])

        #expect(result[spaceA]?.unreadMessageCount == 0)
        #expect(result[spaceA]?.mentions.totalCount == 3)
    }

    @Test func nonParentLayoutsIgnored() {
        let bookmark = makeObject(
            id: "bookmark-1",
            spaceId: spaceA,
            layout: .bookmark,
            discussionId: nil,
            unreadMessageCount: 4,
            unreadMentionCount: 2
        )

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [bookmark], myParticipantIds: [me])

        #expect(result[spaceA] == nil)
    }

    // MARK: - Parents list

    @Test func parents_populatedWithIdAndName() {
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 0,
            unreadMentionCount: 1,
            name: "Doc One"
        )

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent], myParticipantIds: [me])

        let parents = result[spaceA]?.parents ?? []
        #expect(parents.count == 1)
        #expect(parents.first?.id == "parent-1")
        #expect(parents.first?.name == "Doc One")
    }

    @Test func parents_lastMessageDateComesFromDiscussion() {
        let discussionDate = Date(timeIntervalSince1970: 2_000_000)
        let parent = makeParent(
            id: "parent-1",
            spaceId: spaceA,
            discussionId: discussion1,
            unreadMessageCount: 1,
            unreadMentionCount: 0,
            name: "Doc",
            lastMessageDate: nil
        )
        let discussion = makeDiscussion(id: discussion1, subscribers: [me], lastMessageDate: discussionDate)

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent, discussion], myParticipantIds: [me])

        #expect(result[spaceA]?.parents.first?.lastMessageDate == discussionDate)
    }

    @Test func parents_sortedByLastMessageDateDescNilLast() {
        let older = Date(timeIntervalSince1970: 1_000_000)
        let newer = Date(timeIntervalSince1970: 2_000_000)
        let parentOlder = makeParent(
            id: "parent-older", spaceId: spaceA, discussionId: discussion1,
            unreadMessageCount: 1, unreadMentionCount: 0,
            name: "Older"
        )
        let parentNewer = makeParent(
            id: "parent-newer", spaceId: spaceA, discussionId: discussion2,
            unreadMessageCount: 0, unreadMentionCount: 1,
            name: "Newer"
        )
        let parentNoDate = makeParent(
            id: "parent-no-date", spaceId: spaceA, discussionId: "discussion-3",
            unreadMessageCount: 0, unreadMentionCount: 1,
            name: "NoDate"
        )
        let d1 = makeDiscussion(id: discussion1, subscribers: [me], lastMessageDate: older)
        let d2 = makeDiscussion(id: discussion2, subscribers: [me], lastMessageDate: newer)

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(
            items: [parentOlder, parentNoDate, parentNewer, d1, d2],
            myParticipantIds: [me]
        )

        let names = (result[spaceA]?.parents ?? []).map(\.name)
        #expect(names == ["Newer", "Older", "NoDate"])
    }

    @Test func parents_includesBothMentionOnlyAndSubscribed() {
        let mentionOnly = makeParent(
            id: "p-mention", spaceId: spaceA, discussionId: discussion1,
            unreadMessageCount: 0, unreadMentionCount: 2,
            name: "Mention"
        )
        let subscribed = makeParent(
            id: "p-subscribed", spaceId: spaceA, discussionId: discussion2,
            unreadMessageCount: 5, unreadMentionCount: 0,
            name: "Subscribed"
        )
        let d2 = makeDiscussion(id: discussion2, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [mentionOnly, subscribed, d2], myParticipantIds: [me])

        let ids = Set((result[spaceA]?.parents ?? []).map(\.id))
        #expect(ids == ["p-mention", "p-subscribed"])
    }

    // MARK: - Mentions split (subscribed vs unsubscribed)

    @Test func mentions_subscribedParent_unsubscribedCountIsZero() {
        let parent = makeParent(
            id: "parent-1", spaceId: spaceA, discussionId: discussion1,
            unreadMessageCount: 5, unreadMentionCount: 1
        )
        let discussion = makeDiscussion(id: discussion1, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent, discussion], myParticipantIds: [me])

        // Subscribed mentions are already inside unreadMessageCount; nothing leaks into the unsubscribed split.
        #expect(result[spaceA]?.unreadMessageCount == 5)
        #expect(result[spaceA]?.mentions.totalCount == 1)
        #expect(result[spaceA]?.mentions.unsubscribedCount == 0)
    }

    @Test func mentions_unsubscribedParent_totalEqualsUnsubscribed() {
        let parent = makeParent(
            id: "parent-1", spaceId: spaceA, discussionId: discussion1,
            unreadMessageCount: 8, unreadMentionCount: 3
        )

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [parent], myParticipantIds: [me])

        // Unsubscribed parent: messages dropped to 0; mentions land entirely in the unsubscribed bucket.
        #expect(result[spaceA]?.unreadMessageCount == 0)
        #expect(result[spaceA]?.mentions.unsubscribedCount == 3)
        #expect(result[spaceA]?.mentions.totalCount == 3)
    }

    @Test func mentions_mixedParents_combineSubscribedAndUnsubscribed() {
        let subscribed = makeParent(
            id: "p-sub", spaceId: spaceA, discussionId: discussion1,
            unreadMessageCount: 4, unreadMentionCount: 1
        )
        let unsubscribed = makeParent(
            id: "p-unsub", spaceId: spaceA, discussionId: discussion2,
            unreadMessageCount: 9, unreadMentionCount: 2
        )
        let d1 = makeDiscussion(id: discussion1, subscribers: [me])

        let result = ObjectsWithUnreadDiscussionsAggregator.aggregate(items: [subscribed, unsubscribed, d1], myParticipantIds: [me])

        #expect(result[spaceA]?.unreadMessageCount == 4)
        #expect(result[spaceA]?.mentions.unsubscribedCount == 2)
        #expect(result[spaceA]?.mentions.totalCount == 3) // 1 subscribed + 2 unsubscribed
    }

    // MARK: - Fixtures

    private func makeParent(
        id: String,
        spaceId: String,
        discussionId: String,
        unreadMessageCount: Int,
        unreadMentionCount: Int,
        name: String? = nil,
        lastMessageDate: Date? = nil
    ) -> ObjectDetails {
        makeObject(
            id: id,
            spaceId: spaceId,
            layout: .basic,
            discussionId: discussionId,
            unreadMessageCount: unreadMessageCount,
            unreadMentionCount: unreadMentionCount,
            name: name,
            lastMessageDate: lastMessageDate
        )
    }

    private func makeDiscussion(
        id: String,
        subscribers: [String],
        lastMessageDate: Date? = nil
    ) -> ObjectDetails {
        makeObject(
            id: id,
            spaceId: spaceA,
            layout: .discussion,
            discussionId: nil,
            unreadMessageCount: nil,
            unreadMentionCount: nil,
            notificationSubscribers: subscribers,
            lastMessageDate: lastMessageDate
        )
    }

    private func makeObject(
        id: String,
        spaceId: String,
        layout: DetailsLayout,
        discussionId: String?,
        unreadMessageCount: Int?,
        unreadMentionCount: Int?,
        name: String? = nil,
        notificationSubscribers: [String]? = nil,
        lastMessageDate: Date? = nil
    ) -> ObjectDetails {
        var values: [String: Google_Protobuf_Value] = [:]
        values[BundledPropertyKey.spaceId.rawValue] = spaceId.protobufValue
        values[BundledPropertyKey.resolvedLayout.rawValue] = layout.rawValue.protobufValue
        if let discussionId {
            values[BundledPropertyKey.discussionId.rawValue] = discussionId.protobufValue
        }
        if let unreadMessageCount {
            values[BundledPropertyKey.unreadMessageCount.rawValue] = unreadMessageCount.protobufValue
        }
        if let unreadMentionCount {
            values[BundledPropertyKey.unreadMentionCount.rawValue] = unreadMentionCount.protobufValue
        }
        if let name {
            values[BundledPropertyKey.name.rawValue] = name.protobufValue
        }
        if let notificationSubscribers {
            values[BundledPropertyKey.notificationSubscribers.rawValue] = notificationSubscribers.protobufValue
        }
        if let lastMessageDate {
            values[BundledPropertyKey.lastMessageDate.rawValue] = lastMessageDate.protobufValue
        }
        return ObjectDetails(id: id, values: values)
    }
}

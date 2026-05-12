import Testing
import Foundation
@testable import Anytype
import Services

struct SpaceDiscussionsUnreadInfoTests {

    @Test func emptyParents_allTotalsAreZero() {
        let info = SpaceDiscussionsUnreadInfo(parents: [])

        #expect(info.unreadMessageCount == 0)
        #expect(info.unsubscribedMentionCount == 0)
        #expect(info.totalMentionCount == 0)
    }

    @Test func unreadMessageCount_sumsSubscribedOnly() {
        let info = SpaceDiscussionsUnreadInfo(parents: [
            makeParent(id: "a", unreadMessageCount: 3, isSubscribed: true),
            makeParent(id: "b", unreadMessageCount: 4, isSubscribed: true),
            makeParent(id: "c", unreadMessageCount: 7, isSubscribed: false)
        ])

        #expect(info.unreadMessageCount == 7)
    }

    @Test func unsubscribedMentionCount_excludesSubscribed() {
        let info = SpaceDiscussionsUnreadInfo(parents: [
            makeParent(id: "a", unreadMentionCount: 1, isSubscribed: true),
            makeParent(id: "b", unreadMentionCount: 2, isSubscribed: false),
            makeParent(id: "c", unreadMentionCount: 3, isSubscribed: false)
        ])

        #expect(info.unsubscribedMentionCount == 5)
    }

    @Test func totalMentionCount_sumsAll() {
        let info = SpaceDiscussionsUnreadInfo(parents: [
            makeParent(id: "a", unreadMentionCount: 1, isSubscribed: true),
            makeParent(id: "b", unreadMentionCount: 2, isSubscribed: false),
            makeParent(id: "c", unreadMentionCount: 4, isSubscribed: true)
        ])

        #expect(info.totalMentionCount == 7)
    }

    @Test func parents_hasUnreadMention_derivedFromCount() {
        let zero = makeParent(id: "a", unreadMentionCount: 0, isSubscribed: true)
        let nonZero = makeParent(id: "b", unreadMentionCount: 1, isSubscribed: true)

        #expect(zero.hasUnreadMention == false)
        #expect(nonZero.hasUnreadMention == true)
    }

    // MARK: - Fixtures

    private func makeParent(
        id: String,
        unreadMessageCount: Int = 0,
        unreadMentionCount: Int = 0,
        isSubscribed: Bool
    ) -> DiscussionUnreadParent {
        DiscussionUnreadParent(
            details: ObjectDetails(id: id, values: [:]),
            lastMessageDate: nil,
            unreadMessageCount: unreadMessageCount,
            unreadMentionCount: unreadMentionCount,
            isSubscribed: isSubscribed
        )
    }
}

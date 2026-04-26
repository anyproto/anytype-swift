import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf
import AnytypeCore

struct ParentObjectUnreadEntryBuilderTests {

    private let myId = "me"
    private let otherId = "other"
    private let discussionId = "discussion-1"
    private let parentId = "parent-1"

    // MARK: - Truth-table rows (plan section "Aggregate surfaces")

    @Test func row1_unmutedSubscribedNoMention_blueCounterNoMention() {
        let entry = build(unread: 5, mention: 0, subscribed: true, spaceMuted: false)

        #expect(entry?.badge.unreadCounter?.messageCount == 5)
        #expect(entry?.badge.unreadCounter?.style == .blue)
        #expect(entry?.badge.hasMention == false)
        #expect(entry?.badge.appIconContribution == 5)
    }

    @Test func row2_unmutedSubscribedWithMention_blueCounterAndMention() {
        let entry = build(unread: 5, mention: 2, subscribed: true, spaceMuted: false)

        #expect(entry?.badge.unreadCounter?.messageCount == 5)
        #expect(entry?.badge.unreadCounter?.style == .blue)
        #expect(entry?.badge.hasMention == true)
        #expect(entry?.badge.appIconContribution == 5)
    }

    @Test func row3_unmutedNotSubscribedNoMention_filteredOut() {
        let entry = build(unread: 5, mention: 0, subscribed: false, spaceMuted: false)
        #expect(entry == nil)
    }

    @Test func row4_unmutedNotSubscribedWithMention_mentionOnly() {
        let entry = build(unread: 5, mention: 2, subscribed: false, spaceMuted: false)

        #expect(entry?.badge.unreadCounter == nil)
        #expect(entry?.badge.hasMention == true)
        #expect(entry?.badge.appIconContribution == 0)
    }

    @Test func row5_mutedSubscribedNoMention_greyCounterNoMention() {
        let entry = build(unread: 5, mention: 0, subscribed: true, spaceMuted: true)

        #expect(entry?.badge.unreadCounter?.messageCount == 5)
        #expect(entry?.badge.unreadCounter?.style == .grey)
        #expect(entry?.badge.hasMention == false)
        #expect(entry?.badge.appIconContribution == 0)
    }

    @Test func row6_mutedSubscribedWithMention_greyCounterAndMention() {
        let entry = build(unread: 5, mention: 2, subscribed: true, spaceMuted: true)

        #expect(entry?.badge.unreadCounter?.messageCount == 5)
        #expect(entry?.badge.unreadCounter?.style == .grey)
        #expect(entry?.badge.hasMention == true)
        #expect(entry?.badge.appIconContribution == 0)
    }

    @Test func row7_mutedNotSubscribedNoMention_filteredOut() {
        let entry = build(unread: 5, mention: 0, subscribed: false, spaceMuted: true)
        #expect(entry == nil)
    }

    @Test func row8_mutedNotSubscribedWithMention_mentionOnly() {
        let entry = build(unread: 5, mention: 2, subscribed: false, spaceMuted: true)

        #expect(entry?.badge.unreadCounter == nil)
        #expect(entry?.badge.hasMention == true)
        #expect(entry?.badge.appIconContribution == 0)
    }

    // MARK: - Carry-through

    @Test func parentDetailsAndLastMessageDate_carryThrough() {
        let lastMessage = Date(timeIntervalSince1970: 2_000_000)
        let discussion = makeDiscussion(unread: 1, mention: 0, subscribers: [myId], lastMessageDate: lastMessage)
        let parent = ObjectDetails(id: parentId, values: [:])

        let entry = ParentObjectUnreadEntryBuilder.makeEntry(
            discussion: discussion,
            parent: parent,
            myParticipantId: myId,
            spaceMuted: false
        )

        #expect(entry?.id == parentId)
        #expect(entry?.lastMessageDate == lastMessage)
    }

    @Test func nilParticipantId_treatedAsNotSubscribed() {
        let discussion = makeDiscussion(unread: 5, mention: 2, subscribers: [myId], lastMessageDate: nil)
        let entry = ParentObjectUnreadEntryBuilder.makeEntry(
            discussion: discussion,
            parent: ObjectDetails(id: parentId, values: [:]),
            myParticipantId: nil,
            spaceMuted: false
        )

        #expect(entry?.badge.unreadCounter == nil)
        #expect(entry?.badge.hasMention == true)
    }

    // MARK: - Fixtures

    private func build(
        unread: Int,
        mention: Int,
        subscribed: Bool,
        spaceMuted: Bool
    ) -> ParentObjectUnreadEntry? {
        let subscribers = subscribed ? [myId, otherId] : [otherId]
        let discussion = makeDiscussion(
            unread: unread,
            mention: mention,
            subscribers: subscribers,
            lastMessageDate: nil
        )
        return ParentObjectUnreadEntryBuilder.makeEntry(
            discussion: discussion,
            parent: ObjectDetails(id: parentId, values: [:]),
            myParticipantId: myId,
            spaceMuted: spaceMuted
        )
    }

    private func makeDiscussion(
        unread: Int,
        mention: Int,
        subscribers: [String],
        lastMessageDate: Date?
    ) -> ObjectDetails {
        var values: [String: Google_Protobuf_Value] = [:]
        values[BundledPropertyKey.unreadMessageCount.rawValue] = unread.protobufValue
        values[BundledPropertyKey.unreadMentionCount.rawValue] = mention.protobufValue
        values[BundledPropertyKey.notificationSubscribers.rawValue] = subscribers.protobufValue
        if let lastMessageDate {
            values[BundledPropertyKey.lastMessageDate.rawValue] = lastMessageDate.protobufValue
        }
        return ObjectDetails(id: discussionId, values: values)
    }
}

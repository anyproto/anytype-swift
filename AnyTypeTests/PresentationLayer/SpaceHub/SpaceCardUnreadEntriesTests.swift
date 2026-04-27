import Testing
import Foundation
@testable import Anytype

struct SpaceCardUnreadEntriesTests {

    private let older = Date(timeIntervalSince1970: 1_000_000)
    private let middle = Date(timeIntervalSince1970: 2_000_000)
    private let newer = Date(timeIntervalSince1970: 3_000_000)

    // MARK: - Merge / sort

    @Test func merge_chatAndDiscussion_sortsByDateDesc() {
        let chat1 = SpaceCardUnreadEntries.Entry(name: "Chat-Old", date: older)
        let chat2 = SpaceCardUnreadEntries.Entry(name: "Chat-New", date: newer)
        let parent = makeParent(name: "Doc", date: middle)

        let result = SpaceCardUnreadEntries.merge(
            chatEntries: [chat1, chat2],
            discussionParents: [parent]
        )

        #expect(result.map(\.name) == ["Chat-New", "Doc", "Chat-Old"])
    }

    @Test func merge_undatedEntries_goLast() {
        let chat = SpaceCardUnreadEntries.Entry(name: "Chat", date: middle)
        let parent = makeParent(name: "Doc-NoDate", date: nil)
        let parent2 = makeParent(name: "Doc-New", date: newer)

        let result = SpaceCardUnreadEntries.merge(
            chatEntries: [chat],
            discussionParents: [parent, parent2]
        )

        #expect(result.map(\.name) == ["Doc-New", "Chat", "Doc-NoDate"])
    }

    @Test func merge_appliesNamePlaceholderToBlankParent() {
        let parent = makeParent(name: "", date: middle)

        let result = SpaceCardUnreadEntries.merge(
            chatEntries: [],
            discussionParents: [parent]
        )

        #expect(result.first?.name.isEmpty == false)
    }

    @Test func merge_emptyInputs_returnsEmpty() {
        let result = SpaceCardUnreadEntries.merge(chatEntries: [], discussionParents: [])
        #expect(result.isEmpty)
    }

    // MARK: - Compact preview

    @Test func formatCompactPreview_underLimit_joinsWithCommas() {
        let entries: [SpaceCardUnreadEntries.Entry] = [
            .init(name: "A", date: nil),
            .init(name: "B", date: nil)
        ]
        let result = SpaceCardUnreadEntries.formatCompactPreview(entries: entries)
        #expect(result == "A, B")
    }

    @Test func formatCompactPreview_atLimit_noPlusN() {
        let entries: [SpaceCardUnreadEntries.Entry] = [
            .init(name: "A", date: nil),
            .init(name: "B", date: nil),
            .init(name: "C", date: nil)
        ]
        let result = SpaceCardUnreadEntries.formatCompactPreview(entries: entries)
        #expect(result == "A, B, C")
    }

    @Test func formatCompactPreview_overLimit_appendsPlusRemaining() {
        let entries: [SpaceCardUnreadEntries.Entry] = [
            .init(name: "A", date: nil),
            .init(name: "B", date: nil),
            .init(name: "C", date: nil),
            .init(name: "D", date: nil),
            .init(name: "E", date: nil)
        ]
        let result = SpaceCardUnreadEntries.formatCompactPreview(entries: entries)
        #expect(result == "A, B, C +2")
    }

    @Test func formatCompactPreview_empty_returnsNil() {
        let result = SpaceCardUnreadEntries.formatCompactPreview(entries: [])
        #expect(result == nil)
    }

    // MARK: - Fixtures

    private func makeParent(name: String, date: Date?) -> DiscussionUnreadParent {
        DiscussionUnreadParent(
            id: name,
            name: name,
            lastMessageDate: date,
            hasUnreadMention: false
        )
    }
}

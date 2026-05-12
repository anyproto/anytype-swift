import Testing
import Foundation
@testable import Anytype

struct UnreadSectionItemTests {

    @Test func id_chatCase_isPrefixed() {
        let item = UnreadSectionItem.chat(
            UnreadChatWidgetData(id: "abc", spaceId: "space", output: nil),
            lastMessageDate: nil
        )

        #expect(item.id == "chat-abc")
    }

    @Test func id_discussionParentCase_isPrefixed() {
        let item = UnreadSectionItem.discussionParent(
            UnreadDiscussionParentWidgetData(id: "abc", spaceId: "space", output: nil),
            lastMessageDate: nil
        )

        #expect(item.id == "parent-abc")
    }

    @Test func id_chatAndParentWithSameId_doNotCollide() {
        // Defensive: if a parent and a chat object happen to share an id, the prefix avoids ForEach collisions.
        let chat = UnreadSectionItem.chat(
            UnreadChatWidgetData(id: "shared", spaceId: "space", output: nil),
            lastMessageDate: nil
        )
        let parent = UnreadSectionItem.discussionParent(
            UnreadDiscussionParentWidgetData(id: "shared", spaceId: "space", output: nil),
            lastMessageDate: nil
        )

        #expect(chat.id != parent.id)
    }

    @Test func sortDate_returnsLastMessageDate() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let chat = UnreadSectionItem.chat(
            UnreadChatWidgetData(id: "c", spaceId: "s", output: nil),
            lastMessageDate: date
        )
        let parent = UnreadSectionItem.discussionParent(
            UnreadDiscussionParentWidgetData(id: "p", spaceId: "s", output: nil),
            lastMessageDate: date
        )

        #expect(chat.sortDate == date)
        #expect(parent.sortDate == date)
    }

    @Test func sortDate_nilLastMessageDate_returnsDistantPast() {
        let chat = UnreadSectionItem.chat(
            UnreadChatWidgetData(id: "c", spaceId: "s", output: nil),
            lastMessageDate: nil
        )

        #expect(chat.sortDate == .distantPast)
    }

    @Test func sortDate_supportsDescendingMergeOrder() {
        let older = Date(timeIntervalSince1970: 1_000_000)
        let newer = Date(timeIntervalSince1970: 2_000_000)

        let items: [UnreadSectionItem] = [
            .chat(UnreadChatWidgetData(id: "older-chat", spaceId: "s", output: nil), lastMessageDate: older),
            .discussionParent(UnreadDiscussionParentWidgetData(id: "newer-parent", spaceId: "s", output: nil), lastMessageDate: newer),
            .discussionParent(UnreadDiscussionParentWidgetData(id: "no-date", spaceId: "s", output: nil), lastMessageDate: nil)
        ]

        let sorted = items.sorted { $0.sortDate > $1.sortDate }

        #expect(sorted.map(\.id) == ["parent-newer-parent", "chat-older-chat", "parent-no-date"])
    }
}

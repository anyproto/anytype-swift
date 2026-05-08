import Testing
import Foundation
import Services
@testable import Anytype

struct UnreadSectionRowDataTests {

    @Test func sortByLastMessageDate_descending_nilSortsAsDistantPast() {
        let older = Date(timeIntervalSince1970: 1_000_000)
        let newer = Date(timeIntervalSince1970: 2_000_000)

        let rows: [UnreadSectionRowData] = [
            makeRow(id: "older", lastMessageDate: older),
            makeRow(id: "newer", lastMessageDate: newer),
            makeRow(id: "no-date", lastMessageDate: nil)
        ]

        let sorted = rows.sorted { ($0.lastMessageDate ?? .distantPast) > ($1.lastMessageDate ?? .distantPast) }

        #expect(sorted.map(\.id) == ["newer", "older", "no-date"])
    }

    @Test func equatableDistinguishesById() {
        let a = makeRow(id: "a", lastMessageDate: nil)
        let aCopy = makeRow(id: "a", lastMessageDate: nil)
        let b = makeRow(id: "b", lastMessageDate: nil)

        #expect(a == aCopy)
        #expect(a != b)
    }

    private func makeRow(id: String, lastMessageDate: Date?) -> UnreadSectionRowData {
        UnreadSectionRowData(
            id: id,
            details: ObjectDetails(id: id, values: [:]),
            notificationMode: .all,
            unreadMessageCount: 0,
            unreadMentionCount: 0,
            hasUnreadReactions: false,
            isSubscribed: true,
            lastMessageDate: lastMessageDate
        )
    }
}

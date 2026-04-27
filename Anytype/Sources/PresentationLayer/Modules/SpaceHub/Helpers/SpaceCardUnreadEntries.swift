import Foundation
import AnytypeCore

enum SpaceCardUnreadEntries {

    struct Entry: Equatable {
        let name: String
        let date: Date?
    }

    static func merge(
        chatEntries: [Entry],
        discussionParents: [DiscussionUnreadParent]
    ) -> [Entry] {
        var entries = chatEntries
        for parent in discussionParents {
            entries.append(Entry(
                name: parent.name.withPlaceholder,
                date: parent.lastMessageDate
            ))
        }
        return entries.sorted { (lhs: Entry, rhs: Entry) -> Bool in
            (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
        }
    }

    static func formatCompactPreview(entries: [Entry]) -> String? {
        guard entries.isNotEmpty else { return nil }
        let maxVisible = 3
        let visibleNames = entries.prefix(maxVisible).map(\.name)
        let remaining = entries.count - maxVisible
        if remaining > 0 {
            return visibleNames.joined(separator: ", ") + " +\(remaining)"
        } else {
            return visibleNames.joined(separator: ", ")
        }
    }
}

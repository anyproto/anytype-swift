import Foundation
import AnytypeCore

enum ContactsSorter {
    /// Sorts contacts by:
    /// 1. Number of shared spaces (descending)
    /// 2. Has AnyName (contacts with AnyName first)
    /// 3. Name (ascending, case-insensitive)
    static func sorted(_ contacts: [Contact], spaceCounts: [String: Int]) -> [Contact] {
        contacts.sorted { a, b in
            let countA = spaceCounts[a.identity] ?? 0
            let countB = spaceCounts[b.identity] ?? 0
            if countA != countB { return countA > countB }

            let aHasGlobalName = a.globalName.isNotEmpty
            let bHasGlobalName = b.globalName.isNotEmpty
            if aHasGlobalName != bHasGlobalName { return aHasGlobalName }

            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }
}

import Foundation
import AnytypeCore

enum ContactsSorter {
    /// Sorts contacts into three priority groups:
    /// 1. Members with shared spaces — sorted by space count (desc), then name (asc)
    /// 2. Members with no shared spaces but with AnyName — sorted by name (asc)
    /// 3. Members with no shared spaces and no AnyName — sorted by name (asc)
    static func sorted(_ contacts: [Contact], spaceCounts: [String: Int]) -> [Contact] {
        contacts.sorted { a, b in
            let countA = spaceCounts[a.identity] ?? 0
            let countB = spaceCounts[b.identity] ?? 0

            if countA != countB { return countA > countB }

            // AnyName priority only applies within the 0-spaces group
            if countA == 0 {
                let aHasGlobalName = a.globalName.isNotEmpty
                let bHasGlobalName = b.globalName.isNotEmpty
                if aHasGlobalName != bHasGlobalName { return aHasGlobalName }
            }

            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }
}

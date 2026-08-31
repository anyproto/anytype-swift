import Foundation
import Services

enum UnifiedSearchTypeSorter {

    static func sorted<S: Sequence>(
        _ types: S,
        deduplicateByUniqueKey: Bool
    ) -> [ObjectDetails] where S.Element == ObjectDetails {
        let types = Array(types)
        let candidates: [ObjectDetails]

        if deduplicateByUniqueKey {
            candidates = Dictionary(grouping: types, by: \.uniqueKey)
                .values
                .compactMap { $0.sorted(by: isOrderedBefore).first }
        } else {
            candidates = types
        }

        return candidates.sorted(by: isOrderedBefore)
    }

    private static func isOrderedBefore(_ lhs: ObjectDetails, _ rhs: ObjectDetails) -> Bool {
        switch (lhs.lastUsedDate, rhs.lastUsedDate) {
        case let (lhsDate?, rhsDate?) where lhsDate != rhsDate:
            return lhsDate > rhsDate
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            break
        }

        let titleComparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if titleComparison != .orderedSame {
            return titleComparison == .orderedAscending
        }

        let uniqueKeyComparison = lhs.uniqueKey.localizedCaseInsensitiveCompare(rhs.uniqueKey)
        if uniqueKeyComparison != .orderedSame {
            return uniqueKeyComparison == .orderedAscending
        }

        return lhs.id < rhs.id
    }
}

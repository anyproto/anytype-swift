
import Foundation

protocol ComparableDisplayData {
    var title: String? { get }
    var subtitle: String? { get }
    var aliases: [String]? { get }
}

struct SlashMenuComparator {
    private let predicate: (String) -> Bool
    private let result: SlashMenuItemFilterMatch
    
    static func match(data: ComparableDisplayData, string: String) -> SlashMenuItemFilterMatch? {
        let lowecasedTitle = data.title?.lowercased()
        let subtitle = data.subtitle?.lowercased()
        let comparators = [
            SlashMenuComparator(
                predicate: { lowecasedTitle == $0 },
                result: .fullTitle
            ),
            SlashMenuComparator(
                predicate: { lowecasedTitle?.contains($0) ?? false },
                result: .titleSubstring
            ),
            SlashMenuComparator(
                predicate: { subtitle == $0 },
                result: .fullSubtitle
            ),
            SlashMenuComparator(
                predicate: { subtitle?.contains($0) ?? false },
                result: .subtitleSubstring
            ),
            SlashMenuComparator(
                predicate: { search in data.aliases?.contains { $0.contains(search) } ?? false },
                result: .aliaseSubstring
            ),
        ]
        
        return comparators.first { $0.predicate(string.lowercased()) }?.result
    }
}

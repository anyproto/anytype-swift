
import Foundation

protocol ComparableDisplayData {
    var title: String? { get }
    var subtitle: String? { get }
    var aliases: [String]? { get }
}

struct SlashMenuComparator {
    private let predicate: (String) -> Bool
    private let result: SlashMenuItemFilterMatch
    
    @MainActor
    static func match(slashAction: SlashAction, string: String) -> SlashActionFilterMatch? {
        let data = slashAction.displayData
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
                predicate: { search in data.titleSynonyms?.contains { $0.lowercased().contains(search) } ?? false },
                result: .titleSynonymsSubstring
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

        guard let result = comparators.first(where: { $0.predicate(string.lowercased()) })?.result else {
            return nil
        }

        return .init(action: slashAction, filterMatch: result)
    }
}

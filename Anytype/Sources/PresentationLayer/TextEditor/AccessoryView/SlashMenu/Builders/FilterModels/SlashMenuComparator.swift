
import Foundation

protocol ComparableDisplayData {
    var title: String? { get }
    var aliases: [String]? { get }
}

struct SlashMenuComparator {
    private let predicate: (String) -> Bool
    private let result: SlashMenuItemFilterMatch
    
    @MainActor
    static func match(slashAction: SlashAction, string: String, isSingleAction: Bool = false) -> SlashActionFilterMatch? {
        let data = slashAction.displayData
        let title = data.title
        let comparators = [
            SlashMenuComparator(
                predicate: { title?.localizedStandardCompare($0) == .orderedSame },
                result: isSingleAction ? .singleActionFullTitle : .fullTitle
            ),
            SlashMenuComparator(
                predicate: { title?.localizedStandardContains($0) ?? false },
                result: isSingleAction ? .singleActionTitleSubstring : .titleSubstring
            ),
            SlashMenuComparator(
                predicate: { search in data.titleSynonyms?.contains { $0.localizedStandardContains(search) } ?? false },
                result: .titleSynonymsSubstring
            ),
            SlashMenuComparator(
                predicate: { search in data.aliases?.contains { $0.localizedStandardContains(search) } ?? false },
                result: .aliaseSubstring
            ),
        ]

        guard let result = comparators.first(where: { $0.predicate(string) })?.result else {
            return nil
        }

        return .init(action: slashAction, filterMatch: result)
    }
}

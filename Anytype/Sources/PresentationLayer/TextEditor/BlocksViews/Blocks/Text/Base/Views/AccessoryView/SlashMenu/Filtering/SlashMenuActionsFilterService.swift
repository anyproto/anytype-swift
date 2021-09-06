
import Foundation

final class SlashMenuActionsFilterService {
    
    private let initialMenuItems: [BlockActionMenuItem]
    
    init(initialMenuItems: [BlockActionMenuItem]) {
        self.initialMenuItems = initialMenuItems
    }
    
    func menuItemsFiltered(by string: String) -> [SlashMenuCellData] {
        guard !string.isEmpty else {
            return initialMenuItems.map { .menu(item: $0.item, actions: $0.children) }
        }

        let result = initialMenuItems.compactMap { entry -> SlashMenuActionsFilterEntry? in
            var filteredActions: [BlockActionAndFilterMatch] = entry.children.compactMap {
                guard let filterMatch = $0.displayData.matchBy(string: string) else { return nil }
                return BlockActionAndFilterMatch(action: $0, filterMatch: filterMatch)
            }
            filteredActions.sort { $0.filterMatch < $1.filterMatch }
            guard !filteredActions.isEmpty else { return nil }
            return SlashMenuActionsFilterEntry(
                headerTitle: entry.item.title,
                actions: filteredActions.map(\.action)
            )
        }
        
        return result.reduce(into: [SlashMenuCellData]()) { result, filterEntry in
            result.append(.sectionDivider(title: filterEntry.headerTitle))
            result.append(contentsOf: filterEntry.actions.map { .action($0) })
        }
    }
}


import Foundation

final class SlashMenuActionsFilterService {
    
    private let initialMenuItems: [BlockActionMenuItem]
    private let initialFilterEntries: [SlashMenuActionsFilterEntry]
    
    init(initialMenuItems: [BlockActionMenuItem]) {
        self.initialMenuItems = initialMenuItems
        self.initialFilterEntries = initialMenuItems.compactMap { $0.filterEntry() }
    }
    
    func menuItemsFiltered(by string: String) -> [BlockActionMenuItem] {
        guard !string.isEmpty else {
            return initialMenuItems
        }

        let result = initialFilterEntries.compactMap { entry -> SlashMenuActionsFilterEntry? in
            var filteredActions: [BlockActionAndFilterMatch] = entry.actions.compactMap {
                guard let filterMatch = $0.displayData.matchBy(string: string) else { return nil }
                return BlockActionAndFilterMatch(action: $0, filterMatch: filterMatch)
            }
            filteredActions.sort { $0.filterMatch < $1.filterMatch }
            guard !filteredActions.isEmpty else { return nil }
            return SlashMenuActionsFilterEntry(
                headerTitle: entry.headerTitle,
                actions: filteredActions.map(\.action)
            )
        }
        
        return result.reduce(into: [BlockActionMenuItem]()) { result, filterEntry in
            result.append(.sectionDivider(filterEntry.headerTitle))
            result.append(contentsOf: filterEntry.actions.map { .action($0) })
        }
    }
}

fileprivate extension BlockActionMenuItem {
    
    func filterEntry() -> SlashMenuActionsFilterEntry? {
        switch self {
        case .sectionDivider:
            return nil
        case .action:
            return nil
        case let .menu(menuType, items):
            let actions = items.flatMap { $0.actions() }
            return SlashMenuActionsFilterEntry(headerTitle: menuType.title, actions: actions)
        }
    }
}

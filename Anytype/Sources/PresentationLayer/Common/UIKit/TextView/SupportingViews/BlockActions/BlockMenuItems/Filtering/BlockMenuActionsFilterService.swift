
import Foundation

final class BlockMenuActionsFilterService {
    
    let initialMenuItems: [BlockActionMenuItem]
    private lazy var initialFilterEntries = initialMenuItems.compactMap { $0.filterEntry() }
    
    init(initialMenuItems: [BlockActionMenuItem]) {
        self.initialMenuItems = initialMenuItems
    }
    
    func menuItemsFiltered(by string: String) -> [BlockActionMenuItem] {
        // Initialy we have our array with structure - [("Style" [Text, Header]),
        //                                              ("Actions" [Delete, Copy])]
        // after filtering by string "Text" it will be change to ["Style" [Text]]
        // and then converted to menu items - [.divider("Style"),
        //                                     .action(Text)]
        let result = initialFilterEntries.compactMap { entry -> BlockMenuActionsFilterEntry? in
            var filteredActions: [BlockActionAndFilterMatch] = entry.actions.compactMap {
                guard let filterMatch = $0.displayData.matchBy(string: string) else { return nil }
                return BlockActionAndFilterMatch(action: $0, filterMatch: filterMatch)
            }
            filteredActions.sort { $0.filterMatch < $1.filterMatch }
            guard !filteredActions.isEmpty else { return nil }
            return BlockMenuActionsFilterEntry(headerTitle: entry.headerTitle,
                                               actions: filteredActions.map(\.action))
        }
        return result.reduce(into: [BlockActionMenuItem]()) { result, filterEntry in
            result.append(.sectionDivider(filterEntry.headerTitle))
            result.append(contentsOf: filterEntry.actions.map { .action($0) })
        }
    }
}

fileprivate extension BlockActionMenuItem {
    
    func filterEntry() -> BlockMenuActionsFilterEntry? {
        switch self {
        case .sectionDivider:
            return nil
        case .action:
            return nil
        case let .menu(menuType, items):
            let actions = items.flatMap { $0.actions() }
            return BlockMenuActionsFilterEntry(headerTitle: menuType.title, actions: actions)
        }
    }
}

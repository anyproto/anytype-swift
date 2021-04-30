
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
            let filterdActions = entry.actions.filter { $0.displayData.contains(string: string) }
            guard !filterdActions.isEmpty else { return nil }
            return BlockMenuActionsFilterEntry(headerTitle: entry.headerTitle, actions: filterdActions)
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

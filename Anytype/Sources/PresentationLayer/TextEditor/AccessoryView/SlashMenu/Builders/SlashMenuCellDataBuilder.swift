import Foundation
import AnytypeCore

@MainActor
final class SlashMenuCellDataBuilder {
    func build(filter: String = "", menuItems: [SlashMenuItem]) -> [SlashMenuCellData] {
        if filter.isEmpty {
            return menuItems.map { SlashMenuCellData.menu(item: $0) }
        }

        return searchCellData(items: menuItems, filter: filter)
    }
    
    private func searchCellData(items: [SlashMenuItem], filter: String) -> [SlashMenuCellData] {
        items.compactMap { item in
            return filterItem(item: item, filter: filter)
        }
        .sorted(by: { lhs, rhs in
            lhs.topMatch < rhs.topMatch
        })
        .map { filteredItem -> [SlashMenuCellData] in
            searchCellData(title: filteredItem.title, actions: filteredItem.actions)
        }
        .flatMap { $0 }
    }
    
    private func filterItem(item: SlashMenuItem, filter: String) -> SlashMenuFilteredItem? {
        if item.type.title.localizedCaseInsensitiveContains(filter) {
            return SlashMenuFilteredItem(title: item.type.title, topMatch: .groupName, actions: item.children)
        } else {
            return filterItemContent(item: item, filter: filter)
        }
    }
    
    private func filterItemContent(item: SlashMenuItem, filter: String) -> SlashMenuFilteredItem? {
        var filteredActions = filterActions(item: item, filter: filter)
        guard !filteredActions.isEmpty else { return nil }

        filteredActions.sort { $0.filterMatch < $1.filterMatch }

        return SlashMenuFilteredItem(
            title: item.type.title,
            topMatch: filteredActions.first!.filterMatch,
            actions: filteredActions.map { $0.action }
        )
    }
    
    private func filterActions(item: SlashMenuItem, filter: String) -> [SlashActionFilterMatch] {
        return item.children.compactMap {
            switch $0 {
            case let .other(otherAction):
                if case .table = otherAction {
                    return SimpleTableSlashMenuComparator.matchDefaultTable(slashAction: $0, inputString: filter)
                }

                fallthrough
            default:
                return SlashMenuComparator.match(slashAction: $0, string: filter)
            }
        }
    }
    
    private func searchCellData(title: String, actions: [SlashAction]) -> [SlashMenuCellData] {
        guard !actions.isEmpty else { return [] }
        
        var result: [SlashMenuCellData] = [.header(title: title)]
        result.append(contentsOf: actions.map { .action($0) })
        return result
    }
}

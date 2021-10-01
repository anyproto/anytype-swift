import Foundation
import AnytypeCore

final class SlashMenuCellDataBuilder {
    func build(filter: String = "", menuItems: [SlashMenuItem]) -> [SlashMenuCellData] {
        if filter.isEmpty {
            return menuItems.map { SlashMenuCellData.menu(item: $0) }
        }

        return searchCellData(items: menuItems, filter: filter)
    }
    
    private func searchCellData(items: [SlashMenuItem], filter: String) -> [SlashMenuCellData] {
        items.map { item -> [SlashMenuCellData] in
            let actions = actions(item: item, filter: filter)
            return searchCellData(title: item.type.title, actions: actions)
        }.flatMap { $0 }
    }
    
    private func actions(item: SlashMenuItem, filter: String) -> [SlashAction] {
        if item.type.title.localizedCaseInsensitiveContains(filter) {
            return item.children
        } else {
            let filterMatch = filterMatch(item: item, filter: filter)
            return filterMatch.map(\.action)
        }
    }
    
    private func filterMatch(item: SlashMenuItem, filter: String) -> [SlashActionFilterMatch] {
        var filteredActions: [SlashActionFilterMatch] = item.children.compactMap {
            guard let filterMatch = $0.displayData.matchBy(string: filter) else { return nil }
            return SlashActionFilterMatch(action: $0, filterMatch: filterMatch)
        }
        
        filteredActions.sort { $0.filterMatch < $1.filterMatch }
        
        return filteredActions
    }
    
    private func searchCellData(title: String, actions: [SlashAction]) -> [SlashMenuCellData] {
        guard !actions.isEmpty else { return [] }
        
        var result: [SlashMenuCellData] = [.header(title: title)]
        result.append(contentsOf: actions.map { .action($0) })
        return result
    }
}

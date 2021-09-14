import Foundation

final class SlashMenuCellDataBuilder {
    
    private let menuItems: [SlashMenuItem]
    
    init(menuItems: [SlashMenuItem]) {
        self.menuItems = menuItems
    }
    
    func build(filter: String) -> [SlashMenuCellData] {
        guard !filter.isEmpty else {
            return menuItems.map { .menu(item: $0.item, actions: $0.children) }
        }

        return menuItems.flatMap { entry in
            searchCellData(from: entry, filter: filter)
        }
    }
    
    private func searchCellData(from item: SlashMenuItem, filter: String) -> [SlashMenuCellData] {
        guard !item.item.title.localizedCaseInsensitiveContains(filter) else {
            return searchCellData(title: item.item.title, actions: item.children)
        }
        
        var filteredActions: [SlashActionFilterMatch] = item.children.compactMap {
            guard let filterMatch = $0.displayData.matchBy(string: filter) else { return nil }
            return SlashActionFilterMatch(action: $0, filterMatch: filterMatch)
        }
        
        filteredActions.sort { $0.filterMatch < $1.filterMatch }
        
        return searchCellData(title: item.item.title, actions: filteredActions.map(\.action))
    }
    
    private func searchCellData(title: String, actions: [SlashAction]) -> [SlashMenuCellData] {
        guard !actions.isEmpty else { return [] }
        
        var result: [SlashMenuCellData] = [.header(title: title)]
        result.append(contentsOf: actions.map { .action($0) })
        return result
    }
}

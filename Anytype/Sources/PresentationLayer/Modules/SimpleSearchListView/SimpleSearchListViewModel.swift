import SwiftUI
import Services

@MainActor
final class SimpleSearchListViewModel: ObservableObject {
    
    // MARK: - DI
    private let items: [SimpleSearchListItem]
    
    // MARK: - State
    @Published var searchedItems: [SimpleSearchListItem]
    @Published var searchText = ""
    
    init(items: [SimpleSearchListItem]) {
        self.items = items
        self.searchedItems = items
    }
    
    func search() async {
        if searchText.isNotEmpty {
            searchedItems = items.filter {
                $0.title.range(of: searchText, options: .caseInsensitive) != nil
            }
        } else {
            searchedItems = items
        }
    }
}

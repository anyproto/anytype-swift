import SwiftUI
import Services

@MainActor
@Observable
final class SimpleSearchListViewModel {

    // MARK: - DI
    @ObservationIgnored
    private let items: [SimpleSearchListItem]

    // MARK: - State
    var searchedItems: [SimpleSearchListItem]
    var searchText = ""

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

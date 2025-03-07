import Foundation

@MainActor
protocol FilterableItemsView {
    func setFilterText(filterText: String)
}

protocol DismissStatusProvider {
    var shouldDismiss: Bool { get }
}

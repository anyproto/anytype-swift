import Foundation

protocol FilterableItemsView {
    func setFilterText(filterText: String)
}

protocol DismissStatusProvider {
    var shouldDismiss: Bool { get }
}

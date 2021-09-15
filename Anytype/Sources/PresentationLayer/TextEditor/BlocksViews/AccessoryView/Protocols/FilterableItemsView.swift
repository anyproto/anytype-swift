import Foundation

protocol FilterableItemsView {
    func setFilterText(filterText: String)
    func shouldContinueToDisplayView() -> Bool
}

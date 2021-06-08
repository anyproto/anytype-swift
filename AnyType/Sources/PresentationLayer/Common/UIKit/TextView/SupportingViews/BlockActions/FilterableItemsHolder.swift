
import Foundation

protocol FilterableItemsHolder {
    
    func setFilterText(filterText: String)
    func isDisplayingAnyItems() -> Bool
}

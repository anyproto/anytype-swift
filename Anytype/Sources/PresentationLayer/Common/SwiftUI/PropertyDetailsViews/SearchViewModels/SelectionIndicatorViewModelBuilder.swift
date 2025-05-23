import Foundation

final class SelectionIndicatorViewModelBuilder {
    
    static func buildModel(id: String, selectedIds: [String]) -> SelectionIndicatorView.Model {
        guard let index = selectedIds.firstIndex(of: id) else {
            return .notSelected
        }
        
        return .selected(index: index + 1)
    }
    
}

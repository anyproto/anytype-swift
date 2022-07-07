import Foundation

extension NewSearchViewModel {
    
    enum SelectionMode {
        
        case singleItem
        case multipleItems(preselectedIds: [String] = [])
        
        var isPreselectModeAvailable: Bool {
            if case let .multipleItems(preselectedIds) = self, preselectedIds.isNotEmpty {
                return true
            } else {
                return false
            }
        }
        
    }
    
}

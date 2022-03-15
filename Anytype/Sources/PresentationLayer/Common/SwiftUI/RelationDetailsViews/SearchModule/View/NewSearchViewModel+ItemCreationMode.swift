import Foundation

extension NewSearchViewModel {
    
    enum ItemCreationMode {
        case unavailable
        case available(action: (_ title: String) -> Void)
    }
    
}

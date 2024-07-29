import Foundation

extension LegacySearchViewModel {
    
    enum ItemCreationMode {
        case unavailable
        case available(action: (_ title: String) -> Void)
    }
    
}

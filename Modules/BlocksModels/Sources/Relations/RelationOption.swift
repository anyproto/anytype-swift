
import Foundation

public extension Relation {
    
    struct Option: Hashable {
        let id: String
        let text: String
        let color: String
        let scope: Scope = .local
    }
    
}

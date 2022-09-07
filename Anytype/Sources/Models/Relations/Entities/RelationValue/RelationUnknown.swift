import Foundation
import BlocksModels
import CoreImage

extension Relation {
    
    struct Unknown: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: String
        
        static func empty(id: String, key: String, name: String) -> Unknown {
            Unknown(id: id, key: key, name: name, isFeatured: false, isEditable: false, isBundled: false, value: "")
        }
    }
    
}

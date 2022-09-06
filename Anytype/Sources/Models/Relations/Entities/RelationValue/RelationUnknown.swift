import Foundation
import BlocksModels
import CoreImage

extension Relation {
    
    struct Unknown: RelationProtocol, Hashable {
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let value: String
        
        static func empty(key: String, name: String) -> Unknown {
            Unknown(key: key, name: name, isFeatured: false, isEditable: false, isBundled: false, value: "")
        }
    }
    
}

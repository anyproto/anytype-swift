import Foundation
import BlocksModels

extension Relation {
    
    struct Unknown: RelationProtocol, Hashable, Identifiable {
        let id: BlockId
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let value: String
        
        static func empty(id: BlockId, name: String) -> Unknown {
            Unknown(id: id, name: name, isFeatured: false, isEditable: false, value: "")
        }
    }
    
}

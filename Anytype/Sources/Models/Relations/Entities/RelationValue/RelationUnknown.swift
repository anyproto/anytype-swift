import Foundation
import BlocksModels
import CoreImage

extension Relation {
    
    struct Unknown: RelationProtocol, Hashable, Identifiable {
        let id: BlockId
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        let format: RelationMetadata.Format
        
        let value: String
        
        static func empty(id: BlockId, name: String) -> Unknown {
            Unknown(id: id, name: name, isFeatured: false, isEditable: false, isBundled: false, format: .unrecognized, value: "")
        }
    }
    
}

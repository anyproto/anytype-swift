import Foundation

extension Relation {
    
    struct Tag: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let value: [TagRelationValue]
    }
    
}

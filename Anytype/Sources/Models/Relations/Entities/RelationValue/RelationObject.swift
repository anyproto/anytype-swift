import Foundation

extension Relation {
    
    struct Object: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let value: [ObjectRelationValue]
    }
    
}

import Foundation
import BlocksModels

extension Relation {
    
    struct File: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let files: [Option]
    }
    
}

extension Relation.File {
    
    struct Option: Hashable, Identifiable {
        let id: String
        
        let icon: ObjectIconImage
        let title: String
    }
    
}

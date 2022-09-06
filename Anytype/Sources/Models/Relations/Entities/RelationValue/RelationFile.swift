import Foundation
import BlocksModels
import SwiftUI

extension Relation {
    
    struct File: RelationProtocol, Hashable {
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool

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

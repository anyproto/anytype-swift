import Foundation
import BlocksModels
import SwiftUI

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
    
    struct Option: Hashable, Identifiable, RelationOptionProtocol {
        
        let id: String
        
        let icon: ObjectIconImage
        let title: String
        
        func makeView() -> AnyView {
            AnyView(RelationFilesRowView(file: self))
        }
    }
    
}

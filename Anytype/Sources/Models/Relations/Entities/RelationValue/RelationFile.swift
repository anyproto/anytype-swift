import Foundation
import Services
import SwiftUI

extension Relation {
    
    struct File: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isSystem: Bool
        let isDeleted: Bool
        
        let files: [Option]
        
        var hasValue: Bool {
            files.isNotEmpty
        }
    }
    
}

extension Relation.File {
    
    struct Option: Hashable, Identifiable {
        
        let id: String
        
        let icon: ObjectIconImage?
        let title: String
        
        let editorScreenData: EditorScreenData
    }
    
}

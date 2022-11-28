import BlocksModels
import SwiftUI

extension Relation {
    
    struct Object: RelationProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isSystem: Bool
        
        let selectedObjects: [Option]
        let limitedObjectTypes: [String]
        
        var hasValue: Bool {
            selectedObjects.isNotEmpty
        }
    }
    
}

extension Relation.Object {

    struct Option: Hashable, Identifiable {
        let id: String
        
        let icon: ObjectIconImage
        let title: String
        let type: String
        let isArchived: Bool
        let isDeleted: Bool
        let editorViewType: EditorViewType
    }
    
}

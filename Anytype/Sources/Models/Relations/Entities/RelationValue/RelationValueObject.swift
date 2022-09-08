import BlocksModels
import SwiftUI

extension RelationValue {
    
    struct Object: RelationValueProtocol, Hashable, Identifiable {
        let id: String
        let key: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        let isBundled: Bool
        
        let selectedObjects: [Option]
        let limitedObjectTypes: [String]
        
        var hasValue: Bool {
            selectedObjects.isNotEmpty
        }
    }
    
}

extension RelationValue.Object {

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

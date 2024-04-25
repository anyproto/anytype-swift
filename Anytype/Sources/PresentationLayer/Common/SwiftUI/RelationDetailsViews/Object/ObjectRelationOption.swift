import SwiftUI
import Services

struct ObjectRelationOption: Equatable, Identifiable {
    let id: String
    let icon: Icon?
    let title: String
    let type: String
    let isArchived: Bool
    let isDeleted: Bool
    let disableDeletion: Bool
    let disableDuplication: Bool
    
    let editorScreenData: EditorScreenData?
    
    var isUnavailable: Bool {
        isArchived || isDeleted
    }
}

extension ObjectRelationOption {
    init(objectDetails: ObjectDetails) {
        id = objectDetails.id
        icon = objectDetails.objectIconImage
        title = objectDetails.title
        type = objectDetails.objectType.name
        isArchived = objectDetails.isArchived
        isDeleted = objectDetails.isDeleted
        editorScreenData = objectDetails.editorScreenData()
        
        let restrictions = objectDetails.restrictionsValue
        disableDeletion = restrictions.contains(.delete)
        disableDuplication = restrictions.contains(.duplicate)
    }
}


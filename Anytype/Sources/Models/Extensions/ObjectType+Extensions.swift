import Foundation
import Services

extension ObjectType {
    
    public static let emptyType: ObjectType = ObjectType(
        id: "",
        name: "",
        iconEmoji: nil,
        description: "",
        hidden: false,
        readonly: false,
        isArchived: false,
        isDeleted: false,
        sourceObject: "",
        spaceId: "",
        uniqueKey: .empty,
        defaultTemplateId: "",
        canCreateObjectOfThisType: true,
        recommendedRelations: [],
        recommendedFeaturedRelations: [],
        recommendedLayout: nil
    )
    
    var setIsTemplatesAvailable: Bool {
        guard let recommendedLayout else {
            return false
        }
        
        return recommendedLayout.isEditorLayout
    }
    
    var canCreateInChat: Bool {
        // Template is basic layout
        if isTemplateType {
            return false
        }
        
        guard let recommendedLayout else { return false }
        
        return recommendedLayout.isEditorLayout || recommendedLayout.isSet
    }
    
}


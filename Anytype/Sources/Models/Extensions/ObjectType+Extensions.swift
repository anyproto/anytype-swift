import Foundation
import Services

extension ObjectType {
    
    var displayName: String {
        name.isNotEmpty ? name : Loc.untitled
    }
    
    public static let emptyType: ObjectType = ObjectType(
        id: "",
        name: "",
        pluralName: "",
        icon: .defaultObjectIcon,
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
        isDeletable: false,
        layoutAlign: .justify,
        layoutWidth: nil,
        recommendedRelations: [],
        recommendedFeaturedRelations: [],
        recommendedHiddenRelations: [],
        recommendedLayout: nil,
        lastUsedDate: .distantPast
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
    
    // Properties
    var recommendedRelationsDetails: [PropertyDetails] {
        Container.shared.propertyDetailsStorage().relationsDetails(ids: recommendedRelations, spaceId: spaceId)
    }
    var recommendedFeaturedRelationsDetails: [PropertyDetails] {
        Container.shared.propertyDetailsStorage().relationsDetails(ids: recommendedFeaturedRelations, spaceId: spaceId)
    }

    var recommendedHiddenRelationsDetails: [PropertyDetails] {
        Container.shared.propertyDetailsStorage().relationsDetails(ids: recommendedHiddenRelations, spaceId: spaceId)
    }
    
}


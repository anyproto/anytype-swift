import Foundation
import BlocksModels

extension BaseDocumentProtocol {
    // without description, type and editable setOf if needed
    var featuredRelationsForEditor: [Relation] {
        let type = details?.objectType ?? .fallbackType
        let objectRestriction = objectRestrictions.objectRestriction
        
        var enhancedRelations = parsedRelations.featuredRelations
        
        let objectTypeRelationValue: Relation = .text(
            Relation.Text(
                id: BundledRelationKey.type.rawValue,
                key: BundledRelationKey.type.rawValue,
                name: "",
                isFeatured: false,
                isEditable: true, // temp, should be sended from middle
                isSystem: true,
                isDeleted: false,
                isDeletedValue: type.isDeleted,
                value: type.name
            )
        )

        enhancedRelations.insert(objectTypeRelationValue, at: 0)

        enhancedRelations.removeAll { relation in
            relation.key == BundledRelationKey.description.rawValue
        }
        
        let setOfIndex = enhancedRelations.firstIndex { $0.key == BundledRelationKey.setOf.rawValue }
        if !isLocked,
            let setOfIndex,
            let editableRelation = enhancedRelations[setOfIndex].editableRelation
        {
            enhancedRelations[setOfIndex] = editableRelation
        }

        return enhancedRelations
    }
    
}

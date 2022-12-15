import Foundation
import BlocksModels

extension BaseDocumentProtocol {
    // without description and with type
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
                isEditable: !objectRestriction.contains(.typechange),
                isSystem: true,
                isDeletedValue: type.isDeleted,
                value: type.name
            )
        )

        enhancedRelations.insert(objectTypeRelationValue, at: 0)

        enhancedRelations.removeAll { relation in
            relation.key == BundledRelationKey.description.rawValue
        }

        return enhancedRelations
    }
    
}

import Foundation
import BlocksModels

extension BaseDocumentProtocol {
    // without description and with type
    var featuredRelationsForEditor: [Relation] {
        let type = details?.objectType ?? .fallbackType
        let objectRestriction = objectRestrictions.objectRestriction
        
        var enhancedRelations = parsedRelations.featuredRelations
        
        let objectTypeRelation: Relation = .text(
            Relation.Text(
                key: BundledRelationKey.type.rawValue,
                name: "",
                isFeatured: false,
                isEditable: !objectRestriction.contains(.typechange),
                isBundled: true,
                value: type.name
            )
        )

        enhancedRelations.insert(objectTypeRelation, at: 0)

        enhancedRelations.removeAll { relation in
            relation.key == BundledRelationKey.description.rawValue
        }

        return enhancedRelations
    }
    
}

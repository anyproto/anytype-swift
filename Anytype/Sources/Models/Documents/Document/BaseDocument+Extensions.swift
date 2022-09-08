import Foundation
import BlocksModels

extension BaseDocumentProtocol {
    // without description and with type
    var featuredRelationValuessForEditor: [RelationValue] {
        let type = details?.objectType ?? .fallbackType
        let objectRestriction = objectRestrictions.objectRestriction
        
        var enhancedRelationValues = parsedRelations.featuredRelationValues
        
        let objectTypeRelationValue: RelationValue = .text(
            RelationValue.Text(
                id: BundledRelationKey.type.rawValue,
                key: BundledRelationKey.type.rawValue,
                name: "",
                isFeatured: false,
                isEditable: !objectRestriction.contains(.typechange),
                isBundled: true,
                value: type.name
            )
        )

        enhancedRelationValues.insert(objectTypeRelationValue, at: 0)

        enhancedRelationValues.removeAll { relation in
            relation.key == BundledRelationKey.description.rawValue
        }

        return enhancedRelationValues
    }
    
}

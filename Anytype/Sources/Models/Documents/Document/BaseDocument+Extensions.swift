import Foundation
import BlocksModels

extension BaseDocumentProtocol {
    
    var isDocumentEmpty: Bool {

        let haveNonTextAndRelationBlocks = children.contains {
            switch $0.content {
            case .text, .featuredRelations:
                return false
            default:
                return true
            }
        }

        if haveNonTextAndRelationBlocks { return false }

        let textBlocks = children.filter { $0.content.isText }

        switch textBlocks.count {
        case 0, 1:
            return true
        case 2:
            return textBlocks.last?.content.isEmpty ?? false
        default:
            return false
        }
    }
    
    // without description and with type
    var featuredRelationsForEditor: [Relation] {
        let type = details?.objectType ?? .fallbackType
        let objectRestriction = objectRestrictions.objectRestriction
        
        var enhancedRelations = parsedRelations.featuredRelations
        
        let objectTypeRelation: Relation = .text(
            Relation.Text(
                id: BundledRelationKey.type.rawValue,
                name: "",
                isFeatured: false,
                isEditable: !objectRestriction.contains(.typechange),
                isBundled: true,
                value: type.name
            )
        )

        enhancedRelations.insert(objectTypeRelation, at: 0)

        enhancedRelations.removeAll { relation in
            relation.id == BundledRelationKey.description.rawValue
        }

        return enhancedRelations
    }
    
}

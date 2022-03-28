import AnytypeCore
import BlocksModels

struct ParsedRelations {

    let all: [Relation]
    
    let featuredRelations: [Relation]
    let featuredRelationsByIds: [String: Relation]
    let otherRelations: [Relation]
    
    init(featuredRelations: [Relation], otherRelations: [Relation], featuredRelationsByIds: [String: Relation]) {
        self.all = featuredRelations + otherRelations
        self.featuredRelations = featuredRelations
        self.otherRelations = otherRelations
        self.featuredRelationsByIds = featuredRelationsByIds
    }
    
    static let empty = ParsedRelations(featuredRelations: [], otherRelations: [], featuredRelationsByIds: [:])
    
}

extension BaseDocumentProtocol {
    // without description and with type
    func featuredRelationsForEditor() -> [Relation] {
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
                format: .longText,
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

import AnytypeCore
import BlocksModels

struct ParsedRelations {

    let all: [Relation]
    
    let featuredRelations: [Relation]
    let otherRelations: [Relation]
    
    init(featuredRelations: [Relation], otherRelations: [Relation]) {
        self.all = featuredRelations + otherRelations
        self.featuredRelations = featuredRelations
        self.otherRelations = otherRelations
    }
    
    static let empty = ParsedRelations(featuredRelations: [], otherRelations: [])
    
}

extension ParsedRelations {
    // without description and with type
    func featuredRelationsForEditor(type: ObjectType, objectRestriction: [ObjectRestrictions.ObjectRestriction]) -> [Relation] {
        var enhancedRelations = featuredRelations
        
        let objectTypeRelation: Relation = .text(
            Relation.Text(
                id: BundledRelationKey.type.rawValue,
                name: "",
                isFeatured: false,
                isEditable: !objectRestriction.contains(.typechange),
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

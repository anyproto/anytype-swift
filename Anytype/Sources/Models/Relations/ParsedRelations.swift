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
    
    static var empty: ParsedRelations {
        ParsedRelations(featuredRelations: [], otherRelations: [])
    }
    
}

extension ParsedRelations {
    // without description and with type
    func featuredRelationsForEditor(type: ObjectType) -> [Relation] {
        var enhancedRelations = featuredRelations

        let objectTypeRelation = Relation(
            id: BundledRelationKey.type.rawValue,
            name: "",
            value: RelationValue.text(type.name),
            hint: "",
            isFeatured: false,
            isEditable: false
        )

        enhancedRelations.insert(objectTypeRelation, at: 0)

        enhancedRelations.removeAll { relation in
            relation.id == BundledRelationKey.description.rawValue
        }

        return enhancedRelations
    }
}

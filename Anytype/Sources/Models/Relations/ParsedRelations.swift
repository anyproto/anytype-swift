import AnytypeCore
import BlocksModels

struct ParsedRelations {

    let all: [NewRelation]
    
    let featuredRelations: [NewRelation]
    let otherRelations: [NewRelation]
    
    init(featuredRelations: [NewRelation], otherRelations: [NewRelation]) {
        self.all = featuredRelations + otherRelations
        self.featuredRelations = featuredRelations
        self.otherRelations = otherRelations
    }
    
    static let empty = ParsedRelations(featuredRelations: [], otherRelations: [])
    
}

extension ParsedRelations {
    // without description and with type
    func featuredRelationsForEditor(type: ObjectType) -> [NewRelation] {
        var enhancedRelations = featuredRelations
        
        let objectTypeRelation: NewRelation = .text(
            NewRelation.Text(
                id: BundledRelationKey.type.rawValue,
                name: "",
                isFeatured: false, isEditable: false,
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

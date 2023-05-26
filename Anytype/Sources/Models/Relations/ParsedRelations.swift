import AnytypeCore
import Services

struct ParsedRelations: Equatable {

    let installed: [Relation]
    let all: [Relation]
    
    let featuredRelations: [Relation]
    let deletedRelations: [Relation]
    let typeRelations: [Relation]
    let otherRelations: [Relation]
    
    init(
        featuredRelations: [Relation],
        deletedRelations: [Relation],
        typeRelations: [Relation],
        otherRelations: [Relation]
    ){
        self.installed = featuredRelations + otherRelations + typeRelations
        self.all = featuredRelations + deletedRelations + otherRelations + typeRelations
        self.featuredRelations = featuredRelations
        self.deletedRelations = deletedRelations
        self.typeRelations = typeRelations
        self.otherRelations = otherRelations
    }
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(
        featuredRelations: [],
        deletedRelations: [],
        typeRelations: [],
        otherRelations: []
    )
    
}

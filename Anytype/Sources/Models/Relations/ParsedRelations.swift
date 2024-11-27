import AnytypeCore
import Services

struct ParsedRelations: Equatable {
    
    let featuredRelations: [Relation]
    let deletedRelations: [Relation]
    let typeRelations: [Relation]
    let otherRelations: [Relation]
    
    var installed: [Relation] { featuredRelations + otherRelations + typeRelations }
    var installedInObject: [Relation] { featuredRelations + otherRelations }
    var all: [Relation] { featuredRelations + deletedRelations + otherRelations + typeRelations }
    
    init(
        featuredRelations: [Relation],
        deletedRelations: [Relation],
        typeRelations: [Relation],
        otherRelations: [Relation]
    ){
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

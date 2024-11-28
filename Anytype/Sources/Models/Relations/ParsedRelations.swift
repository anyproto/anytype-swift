import AnytypeCore
import Services

struct ParsedRelations: Equatable {
    
    let featuredRelations: [Relation]
    let sidebarRelations: [Relation]
    let conflictedRelations: [Relation]
    let deletedRelations: [Relation]
    
    var installed: [Relation] { featuredRelations + sidebarRelations + conflictedRelations }
    var all: [Relation] { installed + deletedRelations }
    
    init(
        featuredRelations: [Relation],
        sidebarRelations: [Relation],
        conflictedRelations: [Relation],
        deletedRelations: [Relation]
    ){
        self.featuredRelations = featuredRelations
        self.sidebarRelations = sidebarRelations
        self.conflictedRelations = conflictedRelations
        self.deletedRelations = deletedRelations
    }
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(
        featuredRelations: [],
        sidebarRelations: [],
        conflictedRelations: [],
        deletedRelations: []
    )
    
}

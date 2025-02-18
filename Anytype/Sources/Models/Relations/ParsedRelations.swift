import AnytypeCore
import Services

struct ParsedRelations: Equatable {
    
    let featuredRelations: [Relation]
    let sidebarRelations: [Relation]
    let hiddenRelations: [Relation]
    let conflictedRelations: [Relation]
    let deletedRelations: [Relation]
    let systemRelations: [Relation]
    
    var installed: [Relation] { featuredRelations + sidebarRelations + conflictedRelations + hiddenRelations }
    var all: [Relation] { installed + deletedRelations }
    
    init(
        featuredRelations: [Relation],
        sidebarRelations: [Relation],
        hiddenRelations: [Relation],
        conflictedRelations: [Relation],
        deletedRelations: [Relation],
        systemRelations: [Relation]
    ){
        self.featuredRelations = featuredRelations
        self.sidebarRelations = sidebarRelations
        self.hiddenRelations = hiddenRelations
        self.conflictedRelations = conflictedRelations
        self.deletedRelations = deletedRelations
        self.systemRelations = systemRelations
    }
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(
        featuredRelations: [],
        sidebarRelations: [],
        hiddenRelations: [],
        conflictedRelations: [],
        deletedRelations: [],
        systemRelations: []
    )
    
}

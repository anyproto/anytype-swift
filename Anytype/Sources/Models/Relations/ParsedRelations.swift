import AnytypeCore
import Services

struct ParsedRelations: Equatable, Sendable {
    
    let featuredRelations: [Relation]
    let sidebarRelations: [Relation]
    let hiddenRelations: [Relation]
    let conflictedRelations: [Relation]
    let deletedRelations: [Relation]
    let systemRelations: [Relation]
    let legacyFeaturedRelations: [Relation]
    
    var installed: [Relation] { featuredRelations + sidebarRelations + conflictedRelations + hiddenRelations + legacyFeaturedRelations }
    var all: [Relation] { installed + deletedRelations }
    
    init(
        featuredRelations: [Relation],
        sidebarRelations: [Relation],
        hiddenRelations: [Relation],
        conflictedRelations: [Relation],
        deletedRelations: [Relation],
        systemRelations: [Relation],
        legacyFeaturedRelations: [Relation]
    ){
        self.featuredRelations = featuredRelations
        self.sidebarRelations = sidebarRelations
        self.hiddenRelations = hiddenRelations
        self.conflictedRelations = conflictedRelations
        self.deletedRelations = deletedRelations
        self.systemRelations = systemRelations
        self.legacyFeaturedRelations = legacyFeaturedRelations
    }
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(
        featuredRelations: [],
        sidebarRelations: [],
        hiddenRelations: [],
        conflictedRelations: [],
        deletedRelations: [],
        systemRelations: [],
        legacyFeaturedRelations: []
    )
    
}

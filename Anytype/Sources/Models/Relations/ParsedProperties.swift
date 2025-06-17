import AnytypeCore
import Services

struct ParsedProperties: Equatable, Sendable {
    
    let featuredProperties: [Relation]
    let sidebarProperties: [Relation]
    let hiddenProperties: [Relation]
    let conflictedProperties: [Relation]
    let deletedProperties: [Relation]
    let systemProperties: [Relation]
    let legacyFeaturedProperties: [Relation]
    
    var installed: [Relation] { featuredProperties + sidebarProperties + conflictedProperties + hiddenProperties + legacyFeaturedProperties }
    var all: [Relation] { installed + deletedProperties }
    
    init(
        featuredProperties: [Relation],
        sidebarProperties: [Relation],
        hiddenProperties: [Relation],
        conflictedProperties: [Relation],
        deletedProperties: [Relation],
        systemProperties: [Relation],
        legacyFeaturedProperties: [Relation]
    ){
        self.featuredProperties = featuredProperties
        self.sidebarProperties = sidebarProperties
        self.hiddenProperties = hiddenProperties
        self.conflictedProperties = conflictedProperties
        self.deletedProperties = deletedProperties
        self.systemProperties = systemProperties
        self.legacyFeaturedProperties = legacyFeaturedProperties
    }
}

extension ParsedProperties {
    
    static let empty = ParsedProperties(
        featuredProperties: [],
        sidebarProperties: [],
        hiddenProperties: [],
        conflictedProperties: [],
        deletedProperties: [],
        systemProperties: [],
        legacyFeaturedProperties: []
    )
    
}

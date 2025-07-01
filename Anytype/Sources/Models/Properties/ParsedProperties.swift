import AnytypeCore
import Services

struct ParsedProperties: Equatable, Sendable {
    
    let featuredProperties: [Property]
    let sidebarProperties: [Property]
    let hiddenProperties: [Property]
    let conflictedProperties: [Property]
    let deletedProperties: [Property]
    let systemProperties: [Property]
    let legacyFeaturedProperties: [Property]
    
    var installed: [Property] { featuredProperties + sidebarProperties + conflictedProperties + hiddenProperties + legacyFeaturedProperties }
    var all: [Property] { installed + deletedProperties }
    
    init(
        featuredProperties: [Property],
        sidebarProperties: [Property],
        hiddenProperties: [Property],
        conflictedProperties: [Property],
        deletedProperties: [Property],
        systemProperties: [Property],
        legacyFeaturedProperties: [Property]
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

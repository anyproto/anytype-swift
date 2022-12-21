import AnytypeCore
import BlocksModels

struct ParsedRelations: Equatable {

    let installed: [Relation]
    let all: [Relation]
    
    let featuredRelations: [Relation]
    let deletedRelations: [Relation]
    let otherRelations: [Relation]
    
    init(featuredRelations: [Relation], deletedRelations: [Relation], otherRelations: [Relation]) {
        self.installed = featuredRelations + otherRelations
        self.all = featuredRelations + deletedRelations + otherRelations
        self.featuredRelations = featuredRelations
        self.deletedRelations = deletedRelations
        self.otherRelations = otherRelations
    }
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(featuredRelations: [], deletedRelations: [], otherRelations: [])
    
}

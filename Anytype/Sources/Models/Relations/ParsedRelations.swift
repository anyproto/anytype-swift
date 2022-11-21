import AnytypeCore
import BlocksModels

struct ParsedRelations: Equatable {

    let all: [Relation]
    
    let featuredRelations: [Relation]
    let otherRelations: [Relation]
    
    init(featuredRelations: [Relation], otherRelations: [Relation]) {
        self.all = featuredRelations + otherRelations
        self.featuredRelations = featuredRelations
        self.otherRelations = otherRelations
    }
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(featuredRelations: [], otherRelations: [])
    
}

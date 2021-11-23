import AnytypeCore

struct ParsedRelations {

    let all: [Relation]
    
    let featuredRelations: [Relation]
    let otherRelations: [Relation]
    
    init(featuredRelations: [Relation], otherRelations: [Relation]) {
        self.all = featuredRelations + otherRelations
        self.featuredRelations = featuredRelations
        self.otherRelations = otherRelations
    }
    
    static var empty: ParsedRelations {
        ParsedRelations(featuredRelations: [], otherRelations: [])
    }
    
}

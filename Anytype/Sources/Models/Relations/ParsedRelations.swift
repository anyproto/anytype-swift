import AnytypeCore
import BlocksModels

struct ParsedRelations {

    let all: [RelationValue]
    
    let featuredRelationValues: [RelationValue]
    let otherRelationValues: [RelationValue]
    
    init(featuredRelationValues: [RelationValue], otherRelationValues: [RelationValue]) {
        self.all = featuredRelationValues + otherRelationValues
        self.featuredRelationValues = featuredRelationValues
        self.otherRelationValues = otherRelationValues
    }
        
}

extension ParsedRelations {
    
    static let empty = ParsedRelations(featuredRelationValues: [], otherRelationValues: [])
    
}

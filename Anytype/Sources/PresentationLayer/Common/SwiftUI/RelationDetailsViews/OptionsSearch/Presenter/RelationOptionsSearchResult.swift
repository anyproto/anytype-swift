import Foundation
import BlocksModels

enum RelationOptionsSearchResult {
    case objects([ObjectDetails])
    case files([ObjectDetails])
    case tags([Relation.Tag.Option])
    case statuses([Relation.Status.Option])
}

extension RelationOptionsSearchResult {
    
    var asSearchSections: [RelationOptionsSearchSectionModel] {
        RelationOptionsSearchSectionsBuilder.makeSections(using: self)
    }
    
}

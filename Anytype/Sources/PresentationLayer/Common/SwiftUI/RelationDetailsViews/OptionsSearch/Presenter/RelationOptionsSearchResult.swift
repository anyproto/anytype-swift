import Foundation
import BlocksModels

enum RelationOptionsSearchResult {
    case objects([ObjectDetails])
    case files([ObjectDetails])
    case tags([Relation.Tag.Option])
}

extension RelationOptionsSearchResult {
    
    var asSearchSections: [RelationOptionsSearchSectionModel] {
        RelationOptionsSearchSectionsBuilder.makeSections(using: self)
    }
    
}

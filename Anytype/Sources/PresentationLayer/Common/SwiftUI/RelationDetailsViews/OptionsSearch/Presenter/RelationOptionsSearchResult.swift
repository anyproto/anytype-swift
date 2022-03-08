import Foundation
import BlocksModels

enum RelationOptionsSearchResult {
    case objects([ObjectDetails])
    case files([ObjectDetails])
    case tags([Relation.Tag.Option])
}

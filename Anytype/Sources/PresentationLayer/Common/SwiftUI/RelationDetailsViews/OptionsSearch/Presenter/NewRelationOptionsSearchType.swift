import Foundation

enum NewRelationOptionsSearchType {
    case objects
    case files
    case tags([Relation.Tag.Option])
    case statuses([Relation.Status.Option])
}

import Foundation
import BlocksModels

enum RelationOptionSearchItem {
    case object(ObjectDetails)
    case file(ObjectDetails)
    case tag(Relation.Tag.Option)
}

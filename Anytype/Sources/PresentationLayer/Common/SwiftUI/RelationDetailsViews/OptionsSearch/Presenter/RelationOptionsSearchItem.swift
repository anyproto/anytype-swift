import Foundation
import BlocksModels

enum RelationOptionsSearchItem {
    case object(ObjectDetails)
    case file(ObjectDetails)
    case tag(Relation.Tag.Option)
}

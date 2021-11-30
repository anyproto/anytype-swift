import Foundation

enum RelationValue: Hashable {
    case text(String?)
    case number(String?)
    case status(StatusRelationValue?)
    case date(DateRelationValue?)
    case object([ObjectRelationValue])
    case checkbox(Bool)
    case url(String?)
    case email(String?)
    case phone(String?)
    case tag([TagRelationValue])
    case unknown(String)
}

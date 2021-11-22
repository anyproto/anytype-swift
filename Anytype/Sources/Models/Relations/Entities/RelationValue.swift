import Foundation

enum RelationValue: Hashable {
    case text(String?)
    case number(String?)
    case status(StatusRelation?)
    case date(String?)
    case object([ObjectRelation])
    case checkbox(Bool)
    case url(String?)
    case email(String?)
    case phone(String?)
    case tag([TagRelation])
    case unknown(String)
}

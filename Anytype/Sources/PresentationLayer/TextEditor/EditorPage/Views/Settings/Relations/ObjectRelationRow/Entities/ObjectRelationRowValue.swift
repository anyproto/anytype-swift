import Foundation

enum ObjectRelationRowValue: Hashable {
    case text(String?)
    case status(StatusRelation?)
    case file(String?)
    case checkbox(Bool)
    case tag([TagRelation])
    case object([ObjectRelation])
    case unknown(String)
}

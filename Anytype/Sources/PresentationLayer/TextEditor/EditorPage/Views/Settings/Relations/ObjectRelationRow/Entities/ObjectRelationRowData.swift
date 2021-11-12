import Foundation

struct ObjectRelationRowData: Hashable, Identifiable {
    let id: String
    let name: String
    let value: ObjectRelationRowValue
    let hint: String
    let isFeatured: Bool
}

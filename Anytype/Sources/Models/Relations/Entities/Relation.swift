import Foundation

struct Relation: Hashable, Identifiable {
    let id: String
    let name: String
    let value: RelationValue
    let hint: String
    let isFeatured: Bool
    let isEditable: Bool
}

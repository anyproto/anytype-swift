import Foundation

struct ObjectRelationData: Hashable, Identifiable {
    let id: String
    let name: String
    let value: ObjectRelationValue
    let hint: String
    let isFeatured: Bool
    let isEditable: Bool
}

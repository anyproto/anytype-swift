import Foundation

struct RelationValueOptionSection<V: RelationValueOptionProtocol>: Hashable, Identifiable {
    let id: String
    let title: String
    let options: [V]
}

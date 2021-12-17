import Foundation

struct RelationValueOptionSection<Option: RelationValueOptionProtocol>: Hashable, Identifiable {
    let id: String
    let title: String
    let options: [Option]
}

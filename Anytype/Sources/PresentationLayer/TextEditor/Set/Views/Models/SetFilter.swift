import BlocksModels

struct SetFilter: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let filter: DataviewFilter
    
    var id: String { metadata.id }
}

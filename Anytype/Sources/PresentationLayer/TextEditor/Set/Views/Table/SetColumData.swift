import BlocksModels

struct SetColumData {
    let key: String
    let name: String
    let isReadOnly: Bool
    
    init(metadata: RelationMetadata) {
        self.key = metadata.key
        self.name = metadata.name
        self.isReadOnly = metadata.isReadOnly
    }
}

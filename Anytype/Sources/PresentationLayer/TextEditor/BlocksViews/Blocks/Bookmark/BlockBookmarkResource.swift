enum BlockBookmarkState {
    case empty
    case onlyURL(BlockBookmarkPayload)
    case fetched(BlockBookmarkPayload)
}

struct BlockBookmarkPayload {
    let url: String
    let title: String
    let subtitle: String
    let imageHash: String
    let iconHash: String
    
    var hasImage: Bool {
        !imageHash.isEmpty
    }
}

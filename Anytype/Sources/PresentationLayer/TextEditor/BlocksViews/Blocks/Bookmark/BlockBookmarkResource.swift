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

class BlockBookmarkResource {
    
    let state: BlockBookmarkState
    
    required init(state: BlockBookmarkState) {
        self.state = state
    }
    
    static func empty() -> Self {
        .init(state: .empty)
    }
    
    static func onlyURL(_ payload: BlockBookmarkPayload) -> Self {
        .init(state: .onlyURL(payload))
    }
    
    static func fetched(_ payload: BlockBookmarkPayload) -> Self {
        .init(state: .fetched(payload))
    }
}

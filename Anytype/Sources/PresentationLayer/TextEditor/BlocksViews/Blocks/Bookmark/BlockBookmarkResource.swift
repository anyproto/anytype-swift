class BlockBookmarkResource {
    
    let state: State
    var imageLoader: BookmarkImageLoader?
    
    required init(state: State) {
        self.state = state
    }
    
    enum State {
        case empty
        case onlyURL(Payload)
        case fetched(Payload)
    }
    
    struct Payload {
        let url: String?
        let title: String?
        let subtitle: String?
        let imageHash: String?
        let iconHash: String?
        
        func hasImage() -> Bool { !imageHash.isNil }
    }
    
            
    /// We could store images here, for example.
    /// Or we could update images directly.
    /// Or we could store images properties as @Published here.
    static func empty() -> Self {
        .init(state: .empty)
    }
    
    static func onlyURL(_ payload: Payload) -> Self {
        .init(state: .onlyURL(payload))
    }
    
    static func fetched(_ payload: Payload) -> Self {
        .init(state: .fetched(payload))
    }
}

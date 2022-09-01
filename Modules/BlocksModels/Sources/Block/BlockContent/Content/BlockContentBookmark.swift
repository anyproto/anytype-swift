public struct BlockBookmark: Hashable {
    public enum Style {
        case unknown
        case page
        case image
        case text
    }
    
    public enum State {
        case empty
        case fetching
        case done
        case error
    }
    
    public var source: String
    public var title: String
    public var theDescription: String
    public var imageHash: String
    public var faviconHash: String
    public var type: Style
    public var targetObjectID: String
    public var state: State

    // MARK: - Empty
    public static func empty() -> Self {
        .init(source: "", title: "", theDescription: "", imageHash: "", faviconHash: "", type: .unknown, targetObjectID: "", state: .empty)
    }
    
    public static func empty(targetObjectID: String) -> Self {
        .init(source: "", title: "", theDescription: "", imageHash: "", faviconHash: "", type: .unknown, targetObjectID: targetObjectID, state: .done)
    }
    
    // MARK: - Memberwise initializer
    public init(
        source: String,
        title: String,
        theDescription: String,
        imageHash: String,
        faviconHash: String,
        type: Style,
        targetObjectID: String,
        state: State
    ) {
        self.source = source
        self.title = title
        self.theDescription = theDescription
        self.imageHash = imageHash
        self.faviconHash = faviconHash
        self.type = type
        self.targetObjectID = targetObjectID
        self.state = state
    }
}

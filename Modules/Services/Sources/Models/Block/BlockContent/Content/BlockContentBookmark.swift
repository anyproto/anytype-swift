import AnytypeCore

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
    
    public var source: AnytypeURL?
    public var title: String
    public var theDescription: String
    public var imageHash: String
    public var faviconHash: String
    public var type: Style
    public var targetObjectID: String
    public var state: State

    // MARK: - Empty
    public static func empty() -> Self {
        .init(source: nil, title: "", theDescription: "", imageObjectId: "", faviconObjectId: "", type: .unknown, targetObjectID: "", state: .empty)
    }
    
    public static func empty(targetObjectID: String) -> Self {
        .init(source: nil, title: "", theDescription: "", imageObjectId: "", faviconObjectId: "", type: .unknown, targetObjectID: targetObjectID, state: .done)
    }
    
    // MARK: - Memberwise initializer
    public init(
        source: AnytypeURL?,
        title: String,
        theDescription: String,
        imageObjectId: String,
        faviconObjectId: String,
        type: Style,
        targetObjectID: String,
        state: State
    ) {
        self.source = source
        self.title = title
        self.theDescription = theDescription
        self.imageHash = imageObjectId
        self.faviconHash = faviconObjectId
        self.type = type
        self.targetObjectID = targetObjectID
        self.state = state
    }
}

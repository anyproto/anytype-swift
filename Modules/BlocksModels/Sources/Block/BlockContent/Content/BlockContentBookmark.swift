public struct BlockBookmark: Hashable {
    public enum Style {
        case unknown
        case page
        case image
        case text
    }
    
    public var url: String
    public var title: String
    public var theDescription: String
    public var imageHash: String
    public var faviconHash: String
    public var type: Style

    // MARK: - Empty
    public static func empty() -> Self {
        .init(url: "", title: "", theDescription: "", imageHash: "", faviconHash: "", type: .unknown)
    }
    
    // MARK: - Memberwise initializer
    public init(url: String, title: String, theDescription: String, imageHash: String, faviconHash: String, type: Style) {
        self.url = url
        self.title = title
        self.theDescription = theDescription
        self.imageHash = imageHash
        self.faviconHash = faviconHash
        self.type = type
    }
}

public struct BlockFile: Hashable {
    public enum ContentType: Hashable {
        case none
        case file
        case image
        case video
    }
    
    public struct Metadata: Hashable {
        public var name: String
        public var size: Int64
        public var hash: String
        public var mime: String
        public var addedAt: Int64
        
        public static func empty() -> Self {
            .init(name: "", size: 0, hash: "", mime: "", addedAt: 0)
        }
        
        // MARK: - Memberwise initializer
        public init(name: String, size: Int64, hash: String, mime: String, addedAt: Int64) {
            self.name = name
            self.size = size
            self.hash = hash
            self.mime = mime
            self.addedAt = addedAt
        }
    }
    
    public var metadata: Metadata

    /// Our entries
    public var contentType: ContentType
    public var state: BlockFileState

    // MARK: - Designed initializer
    public init(contentType: ContentType) {
        self.init(metadata: .empty(), contentType: contentType, state: .empty)
    }
    
    // MARK: - Memberwise initializer
    public init(metadata: Metadata, contentType: ContentType, state: BlockFileState) {
        self.metadata = metadata
        self.contentType = contentType
        self.state = state
    }
}

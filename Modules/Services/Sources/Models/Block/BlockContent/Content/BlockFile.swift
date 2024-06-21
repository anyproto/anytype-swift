public struct FileMetadata: Hashable, Sendable {
    public var targetObjectId: String
    
    public static func empty() -> Self {
        .init(targetObjectId: "")
    }
    
    // MARK: - Memberwise initializer
    public init(targetObjectId: String) {
        self.targetObjectId = targetObjectId
    }
}


public struct BlockFile: Hashable, Sendable {
    public var metadata: FileMetadata
    public var contentType: FileContentType
    public var state: BlockFileState
    
    public init(metadata: FileMetadata, contentType: FileContentType, state: BlockFileState) {
        self.metadata = metadata
        self.contentType = contentType
        self.state = state
    }
    
    public static func empty(contentType: FileContentType) -> Self {
        BlockFile(metadata: .empty(), contentType: contentType, state: .empty)
    }
}

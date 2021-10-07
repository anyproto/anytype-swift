public typealias FileId = String

public typealias ImageMetadata = FileMetadata
public typealias VideoMetadata = FileMetadata

public struct FileMetadata: Hashable {
    public var name: String
    public var size: Int64
    public var hash: FileId
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


public struct BlockFile: Hashable {
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

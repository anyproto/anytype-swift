import ProtobufMessages

public enum FileContentType: String, Hashable, Sendable {
    case none
    case file
    case image
    case video
    case audio
    
    public init?(_ model: Anytype_Model_Block.Content.File.TypeEnum) {
        switch model {
        case .file: self = .file
        case .image: self = .image
        case .video: self = .video
        case .audio: self = .audio
        case .none: self = .none
        case .UNRECOGNIZED: return nil
        case .pdf: self = .file
        }
    }
    
    public var asMiddleware: Anytype_Model_Block.Content.File.TypeEnum {
        switch self {
        case .none: return .none
        case .file: return .file
        case .image: return .image
        case .video: return .video
        case .audio: return .audio
        }
    }
    
    public var analyticsValue: String {
        switch self {
        case .none: return "none"
        case .file: return "file"
        case .image: return "image"
        case .video: return "video"
        case .audio: return "audio"
        }
    }
}

public struct FileBlockContentData: Hashable, Sendable {
    public let contentType: FileContentType
    
    public init(contentType: FileContentType) {
        self.contentType = contentType
    }
}

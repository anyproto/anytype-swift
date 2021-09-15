import Foundation
import BlocksModels
import ProtobufMessages

final class BlockContentFileContentTypeConverter {
    typealias MiddlewareModel = Anytype_Model_Block.Content.File.TypeEnum
    
    static func asModel(_ value: MiddlewareModel) -> FileContentType? {
        switch value {
        case .none: return .some(.none)
        case .file: return .file
        case .image: return .image
        case .video: return .video
        case .audio: return nil
        case .UNRECOGNIZED: return nil
        case .audio: return nil
        }
    }
    
    static func asMiddleware(_ value: FileContentType) -> MiddlewareModel? {
        switch value {
        case .none: return .some(.none)
        case .file: return .file
        case .image: return .image
        case .video: return .video
        }
    }
}

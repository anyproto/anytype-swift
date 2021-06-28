import Foundation
import BlocksModels
import ProtobufMessages

final class BlockContentFileContentTypeConverter {
    typealias Model = BlockFile.ContentType
    typealias MiddlewareModel = Anytype_Model_Block.Content.File.TypeEnum
    
    static func asModel(_ value: MiddlewareModel) -> Model? {
        switch value {
        case .none: return .some(.none)
        case .file: return .file
        case .image: return .image
        case .video: return .video
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: Model) -> MiddlewareModel? {
        switch value {
        case .none: return .some(.none)
        case .file: return .file
        case .image: return .image
        case .video: return .video
        }
    }
}

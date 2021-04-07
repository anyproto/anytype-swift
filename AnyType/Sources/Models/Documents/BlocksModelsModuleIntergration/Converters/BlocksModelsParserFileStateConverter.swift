import Foundation
import BlocksModels
import ProtobufMessages


final class BlocksModelsParserFileStateConverter {
    typealias Model = TopLevel.BlockContent.File.State
    typealias MiddlewareModel = Anytype_Model_Block.Content.File.State
    
    static func asModel(_ value: MiddlewareModel) -> Model? {
        switch value {
        case .empty: return .empty
        case .uploading: return .uploading
        case .done: return .done
        case .error: return .error
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: Model) -> MiddlewareModel? {
        switch value {
        case .empty: return .empty
        case .uploading: return .uploading
        case .done: return .done
        case .error: return .error
        }
    }
}

import Foundation
import BlocksModels
import ProtobufMessages


final class BlockFileStateConverter {
    typealias MiddlewareModel = Anytype_Model_Block.Content.File.State
    
    static func asModel(_ value: MiddlewareModel) -> BlockFileState? {
        switch value {
        case .empty: return .empty
        case .uploading: return .uploading
        case .done: return .done
        case .error: return .error
        case .UNRECOGNIZED(_):
            return nil
        }
    }
    
    static func asMiddleware(_ value: BlockFileState) -> MiddlewareModel {
        switch value {
        case .empty: return .empty
        case .uploading: return .uploading
        case .done: return .done
        case .error: return .error
        }
    }
}

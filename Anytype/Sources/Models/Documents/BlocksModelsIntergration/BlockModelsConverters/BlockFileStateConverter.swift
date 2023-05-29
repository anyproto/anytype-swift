import Foundation
import BlocksModels
import ProtobufMessages

extension Anytype_Model_Block.Content.File.State {
    var asModel: BlockFileState? {
        switch self {
        case .empty: return .empty
        case .uploading: return .uploading
        case .done: return .done
        case .error: return .error
        case .UNRECOGNIZED(_):
            return nil
        }
    }
}

extension BlockFileState {
    var asMiddleware: Anytype_Model_Block.Content.File.State {
        switch self {
        case .empty: return .empty
        case .uploading: return .uploading
        case .done: return .done
        case .error: return .error
        }
    }
}

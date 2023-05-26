import Foundation
import Services
import ProtobufMessages

extension BlockBookmark.State {
    var asMiddleware: Anytype_Model_Block.Content.Bookmark.State {
        switch self {
        case .empty: return .empty
        case .fetching: return .fetching
        case .done: return .done
        case .error: return .error
        }
    }
}

extension Anytype_Model_Block.Content.Bookmark.State {
    var asModel: BlockBookmark.State {
        switch self {
        case .empty: return .empty
        case .fetching: return .fetching
        case .done: return .done
        case .error: return .error
        case .UNRECOGNIZED: return .error
        }
    }
}

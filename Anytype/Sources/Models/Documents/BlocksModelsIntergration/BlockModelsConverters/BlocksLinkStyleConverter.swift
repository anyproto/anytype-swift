import Foundation
import BlocksModels
import ProtobufMessages

extension Anytype_Model_Block.Content.Link.Style {
    var asModel: BlockLink.Style? {
        switch self {
        case .page: return .page
        case .dataview: return .dataview
        case .archive: return .archive
        case .dashboard: return nil
        case .UNRECOGNIZED: return nil
        }
    }
}

extension BlockLink.Style {
    var asMiddleware: Anytype_Model_Block.Content.Link.Style {
        switch self {
        case .page: return .page
        case .dataview: return .dataview
        case .archive: return .archive
        }
    }
}

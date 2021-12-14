import Foundation
import BlocksModels
import ProtobufMessages

extension Anytype_Model_Block.Content.Layout.Style {
    var asModel: BlockLayout.Style? {
        switch self {
        case .row: return .row
        case .column: return .column
        case .div: return .div
        case .header: return .header
        default: return nil
        }
    }
}

extension BlockLayout.Style {
    var asMiddleware: Anytype_Model_Block.Content.Layout.Style {
        switch self {
        case .row: return .row
        case .column: return .column
        case .div: return .div
        case .header: return .header
        }
    }
}

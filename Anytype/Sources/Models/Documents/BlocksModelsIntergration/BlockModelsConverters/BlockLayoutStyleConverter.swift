import Foundation
import Services
import ProtobufMessages
import AnytypeCore

extension Anytype_Model_Block.Content.Layout.Style {
    var asModel: BlockLayout.Style? {
        switch self {
        case .row: return .row
        case .column: return .column
        case .div: return .div
        case .header: return .header
        case .tableColumns: return .tableColumns
        case .tableRows: return .tableRows
        case .UNRECOGNIZED(let value):
            anytypeAssertionFailure("UNRECOGNIZED block layout style", info: ["value": "\(value)"])
            return nil
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
        case .tableColumns: return .tableColumns
        case .tableRows: return .tableRows
        }
    }
}

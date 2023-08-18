import Foundation
import ProtobufMessages

public extension BlockBookmark.Style {
    var asMiddleware: Anytype_Model_LinkPreview.TypeEnum {
        switch self {
        case .unknown: return .unknown
        case .page: return .page
        case .image: return .image
        case .text: return .text
        }
    }
}

public extension Anytype_Model_LinkPreview.TypeEnum {
    var asModel: BlockBookmark.Style? {
        switch self {
        case .unknown: return .unknown
        case .page: return .page
        case .image: return .image
        case .text: return .text
        case .UNRECOGNIZED: return nil
        }
    }
}

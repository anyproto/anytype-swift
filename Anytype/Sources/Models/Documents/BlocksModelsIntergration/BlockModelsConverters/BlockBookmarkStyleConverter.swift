import Foundation
import Services
import ProtobufMessages

extension BlockBookmark.Style {
    var asMiddleware: Anytype_Model_LinkPreview.TypeEnum {
        switch self {
        case .unknown: return .unknown
        case .page: return .page
        case .image: return .image
        case .text: return .text
        }
    }
}

extension Anytype_Model_LinkPreview.TypeEnum {
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

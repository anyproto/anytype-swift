import Foundation
import BlocksModels
import ProtobufMessages

final class BlocksModelsParserBookmarkTypeEnumConverter {
    typealias Model = BlockBookmark.Style
    typealias MiddlewareModel = Anytype_Model_LinkPreview.TypeEnum

    static func asModel(_ value: MiddlewareModel) -> Model? {
        switch value {
        case .unknown: return .unknown
        case .page: return .page
        case .image: return .image
        case .text: return .text
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: Model) -> MiddlewareModel {
        switch value {
        case .unknown: return .unknown
        case .page: return .page
        case .image: return .image
        case .text: return .text
        }
    }
}

import Foundation
import BlocksModels
import ProtobufMessages

final class BlocksModelsParserLinkStyleConverter {
    typealias Model = BlockContent.Link.Style
    typealias MiddlewareModel = Anytype_Model_Block.Content.Link.Style

    static func asModel(_ value: MiddlewareModel) -> Model? {
        switch value {
        case .page: return .page
        case .dataview: return .dataview
        case .dashboard: return nil
        case .archive: return .archive
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: Model) -> MiddlewareModel? {
        switch value {
        case .page: return .page
        case .dataview: return .dataview
        case .archive: return .archive
        }
    }
}

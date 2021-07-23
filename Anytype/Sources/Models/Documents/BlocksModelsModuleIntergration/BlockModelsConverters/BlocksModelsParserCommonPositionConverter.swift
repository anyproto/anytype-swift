import Foundation
import UIKit
import BlocksModels
import ProtobufMessages


final class BlocksModelsParserCommonPositionConverter {
    /// TODO: Rethink.
    /// Maybe we will move Position and Common structures to `BlocksModels`.
    ///
    typealias MiddlewareModel = Anytype_Model_Block.Position
    
    static func asModel(_ value: MiddlewareModel) -> BlockPosition? {
        switch value {
        case .none: return BlockPosition.none
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .inner: return .inner
        case .replace: return .replace
        default: return nil
        }
    }
    static func asMiddleware(_ value: BlockPosition) -> MiddlewareModel? {
        switch value {
        case .none: return MiddlewareModel.none
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .inner: return .inner
        case .replace: return .replace
        }
    }
}

import Foundation
import UIKit
import BlocksModels
import ProtobufMessages


final class BlocksModelsParserCommonPositionConverter {
    static func asModel(_ value: Anytype_Model_Block.Position) -> BlockPosition? {
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
    static func asMiddleware(_ value: BlockPosition) -> Anytype_Model_Block.Position {
        switch value {
        case .none: return .none
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .inner: return .inner
        case .replace: return .replace
        }
    }
}

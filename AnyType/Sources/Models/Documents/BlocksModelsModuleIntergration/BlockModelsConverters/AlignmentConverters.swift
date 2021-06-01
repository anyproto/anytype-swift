import Foundation
import UIKit
import BlocksModels
import ProtobufMessages


final class BlocksModelsParserCommonAlignmentConverter {
    typealias MiddlewareModel = Anytype_Model_Block.Align
    static func asModel(_ value: MiddlewareModel) -> BlockInformationAlignment? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: BlockInformationAlignment) -> MiddlewareModel? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
}
    
    
// Later it will be separated into textAlignment and contentMode.
final class BlocksModelsParserCommonAlignmentUIKitConverter {
    typealias UIKitModel = NSTextAlignment
    static func asModel(_ value: UIKitModel) -> BlockInformationAlignment? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        default: return nil
        }
    }
    
    static func asUIKitModel(_ value: BlockInformationAlignment) -> UIKitModel? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
}

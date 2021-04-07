import Foundation
import UIKit
import BlocksModels
import ProtobufMessages


final class BlocksModelsParserCommonAlignmentConverter {
    typealias Model = TopLevel.Alignment
    typealias MiddlewareModel = Anytype_Model_Block.Align
    static func asModel(_ value: MiddlewareModel) -> Model? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: Model) -> MiddlewareModel? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
}
    
    
// Later it will be separated into textAlignment and contentMode.
final class BlocksModelsParserCommonAlignmentUIKitConverter {
    typealias Model = TopLevel.Alignment
    typealias UIKitModel = NSTextAlignment
    static func asModel(_ value: UIKitModel) -> Model? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        default: return nil
        }
    }
    
    static func asUIKitModel(_ value: Model) -> UIKitModel? {
        switch value {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
}

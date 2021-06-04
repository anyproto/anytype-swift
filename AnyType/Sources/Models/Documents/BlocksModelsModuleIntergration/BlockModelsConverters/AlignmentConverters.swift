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
extension NSTextAlignment {
    
    var asBlockInformationAlignment: BlockInformationAlignment? {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        default: return nil
        }
    }
    
}

extension BlockInformationAlignment {
    
    var asTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
    
}

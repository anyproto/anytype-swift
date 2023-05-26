import Foundation
import UIKit
import SwiftUI
import Services
import ProtobufMessages

extension Anytype_Model_Block.Align {
    var asBlockModel: LayoutAlignment? {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .UNRECOGNIZED: return nil
        }
    }
}

extension LayoutAlignment {
    var asMiddleware: Anytype_Model_Block.Align {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
    
    var asNSTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
}

extension NSTextAlignment {
    
    var asMiddleware: Anytype_Model_Block.Align? {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
            
        case .justified, .natural:
            return nil
        @unknown default:
            return nil
        }
    }

    var asModel: LayoutAlignment? {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right

        case .justified, .natural:
            return nil
        @unknown default:
            return nil
        }
    }
}


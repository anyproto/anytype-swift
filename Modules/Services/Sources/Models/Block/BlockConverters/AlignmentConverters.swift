import Foundation
import UIKit
import ProtobufMessages

public extension LayoutAlignment {
    
    var asNSTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justify: return .justified
        case .UNRECOGNIZED: return .left
        }
    }
}

public extension NSTextAlignment {
    
    var asModel: LayoutAlignment? {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified:
            return .justify
        case .natural:
            return nil
        @unknown default:
            return nil
        }
    }
}



import UIKit

enum BlockColorAction: CaseIterable {
    case black
    case lemon
    case amber
    case red
    case pink
    case purple
    case ultramarine
    
    var color: UIColor {
        switch self {
        case .amber:
            return .amber
        case .black:
            return .black
        case .lemon:
            return .lemon
        case .red:
            return .red
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .ultramarine:
            return .ultramarine
        }
    }
}


import UIKit

enum BlockBackgroundColorAction: CaseIterable {
    case `default`
    case lemon
    case amber
    case red
    case pink
    case purple
    case ultramarine
    
    var color : UIColor {
        switch self {
        case .default:
            return .defaultBackgroundColor
        case .lemon:
            return .lemonBackground
        case .amber:
            return .amberBackground
        case .red:
            return .redBackground
        case .pink:
            return .pinkBackground
        case .purple:
            return .purpleBackground
        case .ultramarine:
            return .ultramarineBackground
        }
    }
}

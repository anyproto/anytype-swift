
import UIKit
import BlocksModels

enum BlockBackgroundColor: CaseIterable {
    case `default`
    case gray
    case lemon
    case amber
    case red
    case pink
    case purple
    case blue
    case sky
    case teal
    case green
    
    var color : UIColor {
        typealias ColorComponent = UIColor.Background
        switch self {
        case .default:
            return ColorComponent.default
        case .lemon:
            return ColorComponent.yellow
        case .amber:
            return ColorComponent.amber
        case .red:
            return ColorComponent.red
        case .pink:
            return ColorComponent.pink
        case .purple:
            return ColorComponent.purple
        case .sky:
            return ColorComponent.sky
        case .blue:
            return ColorComponent.blue
        case .teal:
            return ColorComponent.teal
        case .green:
            return ColorComponent.green
        case .gray:
            return ColorComponent.grey
        }
    }
    
    var title: String {
        switch self {
        case .lemon:
            return "Yellow background".localized
        case .default:
            return "Default background".localized
        case .amber:
            return "Amber background".localized
        case .red:
            return "Red background".localized
        case .pink:
            return "Pink background".localized
        case .purple:
            return "Purple background".localized
        case .sky:
            return "Sky background".localized
        case .blue:
            return "Blue background".localized
        case .teal:
            return "Teal background".localized
        case .green:
            return "Green background".localized
        case .gray:
            return "Grey background".localized
        }
    }
    
    var image: UIImage {
        UIImage.circleImage(
            size: .init(width: 22, height: 22),
            fillColor: color,
            borderColor: .strokePrimary,
            borderWidth: 1
        )
    }

    var middleware: MiddlewareColor {
        switch self {
        case .default:
            return .default
        case .lemon:
            return .yellow
        case .amber:
            return .orange
        case .red:
            return .red
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .sky:
            return .ice
        case .blue:
            return .blue
        case .teal:
            return .teal
        case .green:
            return .lime
        case .gray:
            return .grey
        }
    }
}

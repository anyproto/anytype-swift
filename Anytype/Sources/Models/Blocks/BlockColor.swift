import UIKit
import BlocksModels

enum BlockColor: CaseIterable {
    case black
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
    
    var color: UIColor {
        typealias ColorComponent = UIColor.Text
        switch self {
        case .amber:
            return ColorComponent.amber
        case .black:
            return ColorComponent.`default`
        case .lemon:
            return ColorComponent.yellow
        case .red:
            return ColorComponent.red
        case .pink:
            return ColorComponent.pink
        case .purple:
            return ColorComponent.purple
        case .blue:
            return ColorComponent.blue
        case .sky:
            return ColorComponent.sky
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
        case .black:
            return "Black".localized
        case .lemon:
            return "Yellow".localized
        case .amber:
            return "Amber".localized
        case .red:
            return "Red".localized
        case .pink:
            return "Pink".localized
        case .purple:
            return "Purple".localized
        case .blue:
            return "Blue".localized
        case .sky:
            return "Sky".localized
        case .teal:
            return "Teal".localized
        case .green:
            return "Green".localized
        case .gray:
            return "Grey".localized
        }
    }
    
    var image: UIImage {
        UIImage.circleImage(
            size: .init(width: 22, height: 22),
            fillColor: color,
            borderColor: .clear,
            borderWidth: 0
        )
    }
    
    var middleware: MiddlewareColor {
        switch self {
        case .black:
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
        case .blue:
            return .blue
        case .sky:
            return .ice
        case .teal:
            return .teal
        case .green:
            return .lime
        case .gray:
            return .grey
        }
    }
}

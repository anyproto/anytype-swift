import UIKit
import Services

enum BlockColor: CaseIterable {
    case black
    case gray
    case lemon
    case orange
    case red
    case pink
    case purple
    case blue
    case sky
    case teal
    case green
    
    var color: UIColor {
        typealias ColorComponent = UIColor.Dark
        switch self {
        case .orange:
            return ColorComponent.orange
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
            return Loc.black
        case .lemon:
            return Loc.yellow
        case .orange:
            return Loc.amber
        case .red:
            return Loc.red
        case .pink:
            return Loc.pink
        case .purple:
            return Loc.purple
        case .blue:
            return Loc.blue
        case .sky:
            return Loc.sky
        case .teal:
            return Loc.teal
        case .green:
            return Loc.green
        case .gray:
            return Loc.grey
        }
    }
    
    @MainActor
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
        case .orange:
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


import UIKit
import Services
import SwiftUI

enum BlockBackgroundColor: String, CaseIterable {
    case `default`
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
    
    var color : UIColor {
        typealias ColorComponent = UIColor.VeryLight
        switch self {
        case .default:
            return ColorComponent.default
        case .lemon:
            return ColorComponent.yellow
        case .orange:
            return ColorComponent.orange
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
    
    var swiftColor : Color {
        typealias ColorComponent = Color.VeryLight
        switch self {
        case .default:
            return ColorComponent.default
        case .lemon:
            return ColorComponent.yellow
        case .orange:
            return ColorComponent.orange
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
    
    var tagColor : UIColor {
        typealias ColorComponent = UIColor.Light
        switch self {
        case .default:
            return ColorComponent.default
        case .lemon:
            return ColorComponent.yellow
        case .orange:
            return ColorComponent.orange
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
            return Loc.yellowBackground
        case .default:
            return Loc.defaultBackground
        case .orange:
            return Loc.amberBackground
        case .red:
            return Loc.redBackground
        case .pink:
            return Loc.pinkBackground
        case .purple:
            return Loc.purpleBackground
        case .sky:
            return Loc.skyBackground
        case .blue:
            return Loc.blueBackground
        case .teal:
            return Loc.tealBackground
        case .green:
            return Loc.greenBackground
        case .gray:
            return Loc.greyBackground
        }
    }
    
    @MainActor
    var image: UIImage {
        UIImage.circleImage(
            size: .init(width: 22, height: 22),
            fillColor: color,
            borderColor: .Shape.primary,
            borderWidth: 1
        )
    }

    var middleware: MiddlewareColor {
        switch self {
        case .default:
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

extension MiddlewareColor {
    var backgroundColor: BlockBackgroundColor {
        switch self {
        case .default:
            return .default
        case .grey:
            return .gray
        case .yellow:
            return .lemon
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
        case .ice:
            return .sky
        case .teal:
            return .teal
        case .lime:
            return .green
        }
    }
}

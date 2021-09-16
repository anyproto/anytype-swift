
import UIKit
import BlocksModels

enum BlockBackgroundColor: CaseIterable {
    case `default`
    case coldGray
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
        switch self {
        case .default:
            return .backgroundPrimary
        case .lemon:
            return .lightLemon
        case .amber:
            return .lightAmber
        case .red:
            return .lightRed
        case .pink:
            return .lightPink
        case .purple:
            return .lightPurple
        case .sky:
            return .lightBlue
        case .blue:
            return .lightUltramarine
        case .teal:
            return .lightTeal
        case .green:
            return .lightGreen
        case .coldGray:
            return .lightColdGray
        }
    }
    
    var title: String {
        switch self {
        case .lemon:
            return "Lemon background".localized
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
        case .coldGray:
            return "Coldgray background".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .lemon:
            return ImageName.slashMenu.background_color.lemon
        case .default:
            return ImageName.slashMenu.background_color.clear
        case .amber:
            return ImageName.slashMenu.background_color.amber
        case .red:
            return ImageName.slashMenu.background_color.red
        case .pink:
            return ImageName.slashMenu.background_color.pink
        case .purple:
            return ImageName.slashMenu.background_color.purple
        case .sky:
            return ImageName.slashMenu.background_color.ultramarine
        case .blue:
            return ImageName.slashMenu.background_color.blue
        case .teal:
            return ImageName.slashMenu.background_color.teal
        case .green:
            return ImageName.slashMenu.background_color.green
        case .coldGray:
            return ImageName.slashMenu.background_color.coldgray
        }
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
        case .coldGray:
            return .grey
        }
    }
}

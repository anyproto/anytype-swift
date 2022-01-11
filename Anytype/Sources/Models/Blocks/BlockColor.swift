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
        typealias Component = UIColor.TagBackground
        switch self {
        case .amber:
            return Component.amber
        case .black:
            return .textPrimary
        case .lemon:
            return Component.yellow
        case .red:
            return Component.red
        case .pink:
            return Component.pink
        case .purple:
            return Component.purple
        case .blue:
            return Component.blue
        case .sky:
            return Component.sky
        case .teal:
            return Component.teal
        case .green:
            return Component.green
        case .gray:
            return Component.grey
        }
    }
    
    
    var title: String {
        switch self {
        case .black:
            return "Black".localized
        case .lemon:
            return "Lemon".localized
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
    
    var iconName: String {
        switch self {
        case .lemon:
            return ImageName.slashMenu.color.lemon
        case .black:
            return ImageName.slashMenu.color.black
        case .amber:
            return ImageName.slashMenu.color.amber
        case .red:
            return ImageName.slashMenu.color.red
        case .pink:
            return ImageName.slashMenu.color.pink
        case .purple:
            return ImageName.slashMenu.color.purple
        case .blue:
            return ImageName.slashMenu.color.blue
        case .sky:
            return ImageName.slashMenu.color.sky
        case .teal:
            return ImageName.slashMenu.color.teal
        case .green:
            return ImageName.slashMenu.color.green
        case .gray:
            return ImageName.slashMenu.color.gray
        }
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

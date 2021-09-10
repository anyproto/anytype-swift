import UIKit
import BlocksModels

enum BlockColor: CaseIterable {
    case black
    case lemon
    case amber
    case red
    case pink
    case purple
    case ultramarine
    case blue
    case teal
    case green
    case coldgray
    
    var color: UIColor {
        switch self {
        case .amber:
            return .pureAmber
        case .black:
            return .grayscale90
        case .lemon:
            return .pureLemon
        case .red:
            return .pureRed
        case .pink:
            return .purePink
        case .purple:
            return .purePurple
        case .ultramarine:
            return .pureUltramarine
        case .blue:
            return .pureBlue
        case .teal:
            return .pureTeal
        case .green:
            return .pureGreen
        case .coldgray:
            return .darkColdGray
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
        case .ultramarine:
            return "Ultramarine".localized
        case .blue:
            return "Blue".localized
        case .teal:
            return "Teal".localized
        case .green:
            return "Green".localized
        case .coldgray:
            return "Coldgray".localized
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
        case .ultramarine:
            return ImageName.slashMenu.color.ultramarine
        case .blue:
            return ImageName.slashMenu.color.blue
        case .teal:
            return ImageName.slashMenu.color.teal
        case .green:
            return ImageName.slashMenu.color.green
        case .coldgray:
            return ImageName.slashMenu.color.coldgray
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
        case .ultramarine:
            return .blue
        case .blue:
            return .ice
        case .teal:
            return .teal
        case .green:
            return .lime
        case .coldgray:
            return .grey
        }
    }
}

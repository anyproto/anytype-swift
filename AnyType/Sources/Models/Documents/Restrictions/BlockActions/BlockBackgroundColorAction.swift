
import UIKit

enum BlockBackgroundColorAction: CaseIterable {
    case `default`
    case lemon
    case amber
    case red
    case pink
    case purple
    case ultramarine
    case blue
    case teal
    case green
    case coldGray
    
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
        case .blue:
            return .blueBackground
        case .teal:
            return .tealBackground
        case .green:
            return .greenBackground
        case .coldGray:
            return .coldgrayBackground
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
        case .ultramarine:
            return "Ultramarine background".localized
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
            return "TextEditor/Toolbar/Blocks/BackgroundColorLemon"
        case .default:
            return "TextEditor/Toolbar/Blocks/BackgroundColorClear"
        case .amber:
            return "TextEditor/Toolbar/Blocks/BackgroundColorAmber"
        case .red:
            return "TextEditor/Toolbar/Blocks/BackgroundColorRed"
        case .pink:
            return "TextEditor/Toolbar/Blocks/BackgroundColorPink"
        case .purple:
            return "TextEditor/Toolbar/Blocks/BackgroundColorPurple"
        case .ultramarine:
            return "TextEditor/Toolbar/Blocks/BackgroundColorUltramarine"
        case .blue:
            return "TextEditor/Toolbar/Blocks/BackgroundColorBlue"
        case .teal:
            return "TextEditor/Toolbar/Blocks/BackgroundColorTeal"
        case .green:
            return "TextEditor/Toolbar/Blocks/BackgroundColorGreen"
        case .coldGray:
            return "TextEditor/Toolbar/Blocks/BackgroundColorColdgray"
        }
    }
}

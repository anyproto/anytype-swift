
import UIKit

enum BlockBackgroundColor: CaseIterable {
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
            return .grayscaleWhite
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
        case .ultramarine:
            return .lightUltramarine
        case .blue:
            return .lightBlue
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

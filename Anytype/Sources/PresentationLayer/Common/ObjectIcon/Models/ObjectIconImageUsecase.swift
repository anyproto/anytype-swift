import Foundation
import UIKit

//@see https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=123%3A981
enum ObjectIconImageUsecase: Equatable {
    case openedObject
    case openedObjectNavigationBar
    
    case editorSearch // slash menu + mention
    
    case dashboardList
    case dashboardProfile
    case dashboardSearch
    case mention(ObjectIconImageMentionType)
    case editorAccessorySearch
}

extension ObjectIconImageUsecase {
    var backgroundColor: UIColor {
        switch self {
        case .openedObjectNavigationBar, .mention:
            return .clear
        default:
            return UIColor.grayscale10
        }
    }
}

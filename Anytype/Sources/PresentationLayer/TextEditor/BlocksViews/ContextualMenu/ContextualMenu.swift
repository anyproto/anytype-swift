import UIKit

enum ContextualMenu: String {
    case addBlockBelow
    case delete
    case duplicate
    case turnIntoPage
    
    // Text
    case style
    
    // Files
    case download
    case replace
    
    var identifier: UIAction.Identifier {
        UIAction.Identifier(rawValue)
    }
}

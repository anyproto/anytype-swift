import Foundation
import UIKit

//@see https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=123%3A981
enum ObjectIconImageUsecase: Equatable, Hashable {
    case openedObject
    case openedObjectNavigationBar
    
    case editorSearch // slash menu + mention
    case editorSearchExpandedIcons
    case editorCalloutBlock
    case linkToObject
    
    case dashboardList
    case dashboardProfile
    case dashboardSearch
    case mention(ObjectIconImageMentionType)
    case editorAccessorySearch
    
    case featuredRelationsBlock
    
    case setRow
    case setCollection
    
    case widgetTree
    case widgetList
    case homeBottomPanel
    case settingsHeader
    case settingsSection

    case inlineSetHeader
    case templatePreview
    case fileStorage
}

extension ObjectIconImageUsecase {
    var profileBackgroundColor: UIColor {
        switch self {
        case .openedObject: return .Stroke.primary
        default: return .Stroke.secondary
        }
    }
    
    var spaceBackgroundColor: UIColor {
        .Stroke.secondary
    }
    
    var placeholderBackgroundColor: UIColor {
        .Stroke.transperent
    }
    
    var emojiBackgroundColor: UIColor {
        switch self {
        case .openedObjectNavigationBar, .mention, .setRow, .featuredRelationsBlock, .editorCalloutBlock,
                .inlineSetHeader, .widgetTree, .homeBottomPanel:
            return .clear
        default:
            return .Stroke.transperent
        }
    }
}

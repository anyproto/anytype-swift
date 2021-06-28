import Foundation
import UIKit

struct ContextualMenu {
    let title: String
    let children: [ContextualMenuActionData]
    
    init(title: String, children: [ContextualMenuActionData] = []) {
        self.title = title
        self.children = children
    }
}

struct ContextualMenuActionData {
    let title: String
    let image: UIImage?
    
    let identifier: String
    let action: ContextualMenuAction
    let children: [ContextualMenuActionData]
    
    init(action: ContextualMenuAction, children: [ContextualMenuActionData] = []) {
        self.title = ContextualMenuTitleProvider.title(for: action)
        self.image = UIImage.init(named: ContextualMenuImageProvider.imagePath(for: action))
        
        self.action = action
        self.identifier = ContextualMenuIdentifierBuilder.identifier(for: action)
        self.children = children
    }
}

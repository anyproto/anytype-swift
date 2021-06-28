import Foundation
import UIKit

struct ContextualMenu {
    let title: String
    let children: [ContextualMenuData]
    
    init(title: String, children: [ContextualMenuData] = []) {
        self.title = title
        self.children = children
    }
}

struct ContextualMenuData {
    let title: String
    let image: UIImage?
    
    let identifier: String
    let action: ContextualMenuAction
    let children: [ContextualMenuData]
    
    init(action: ContextualMenuAction, children: [ContextualMenuData] = []) {
        self.title = ContextualMenuTitleProvider.title(for: action)
        self.image = UIImage(named: ContextualMenuImageProvider.imagePath(for: action))
        
        self.action = action
        self.identifier = ContextualMenuIdentifierBuilder.identifier(for: action)
        self.children = children
    }
}

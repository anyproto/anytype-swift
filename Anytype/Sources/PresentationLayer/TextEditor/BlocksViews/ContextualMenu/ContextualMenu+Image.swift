import UIKit

extension ContextualMenu {
    
    var image: UIImage? {
        UIImage(named: imagePath)
    }
    
    private var imagePath: String {
        switch self {
        case .addBlockBelow: return "TextEditor/ContextMenu/addBlockBelow"
        case .delete: return "TextEditor/ContextMenu/delete"
        case .duplicate: return "TextEditor/ContextMenu/duplicate"
        case .turnIntoPage: return "TextEditor/ContextMenu/turnInto"
        case .style: return "TextEditor/ContextMenu/style"
        case .download: return "TextEditor/ContextMenu/download"
        case .replace: return "TextEditor/ContextMenu/replace"
        }
    }
}

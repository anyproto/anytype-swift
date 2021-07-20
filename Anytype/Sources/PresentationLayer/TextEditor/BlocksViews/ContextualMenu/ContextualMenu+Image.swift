import UIKit

extension ContextualMenu {
    
    var image: UIImage? {
        UIImage(named: imagePath)
    }
    
    private var imagePath: String {
        switch self {
        case .addBlockBelow: return "TextEditor/ContextMenu/General/addBlockBelow"
        case .delete: return "TextEditor/ContextMenu/General/delete"
        case .duplicate: return "TextEditor/ContextMenu/General/duplicate"
        case .turnIntoPage: return "TextEditor/ContextMenu/Specific/turnInto"
        case .style: return "TextEditor/ContextMenu/Specific/style"
        case .download: return "TextEditor/ContextMenu/Specific/download"
        case .replace: return "TextEditor/ContextMenu/Specific/replace"
        }
    }
}

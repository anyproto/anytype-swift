struct ContextualMenuImageProvider {
    static func imagePath(for action: ContextualMenuAction) -> String {
        switch action {
        case .addBlockBelow: return "TextEditor/ContextMenu/General/addBlockBelow"
        case .delete: return "TextEditor/ContextMenu/General/delete"
        case .duplicate: return "TextEditor/ContextMenu/General/duplicate"
        case .moveTo: return "TextEditor/ContextMenu/General/moveTo"
        case .turnIntoPage: return "TextEditor/ContextMenu/Specific/turnInto"
        case .style: return "TextEditor/ContextMenu/Specific/style"
        case .color: return ""
        case .backgroundColor: return ""
        case .download: return "TextEditor/ContextMenu/Specific/download"
        case .replace: return "TextEditor/ContextMenu/Specific/replace"
        case .addCaption: return "TextEditor/ContextMenu/Specific/addCaption"
        case .rename: return "TextEditor/ContextMenu/Specific/rename"
        }
    }
}

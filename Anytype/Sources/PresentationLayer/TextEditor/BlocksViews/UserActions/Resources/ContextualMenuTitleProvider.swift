import Foundation

struct ContextualMenuTitleProvider {
    static func title(for action: ContextualMenuAction) -> String {
        NSLocalizedString(
            self.resourceKey(for: action),
            tableName: "TextEditor.ContextualMenu.Actions",
            bundle: .main,
            value: "",
            comment: ""
        )
    }
    
    private static func resourceKey(for action: ContextualMenuAction) -> String {
        switch action {
        case .addBlockBelow: return "General.AddBlockBelow"
        case .delete: return "General.Delete"
        case .duplicate: return "General.Duplicate"
        case .moveTo: return "General.MoveTo"
        case .turnIntoPage: return "Specific.TurnIntoPage"
        case .style: return "Specific.Style"
        case .color: return "Specific.Color"
        case .backgroundColor: return "Specific.BackgroundColor"
        case .download: return "Specific.Download"
        case .replace: return "Specific.Replace"
        case .addCaption: return "Specific.AddCaption"
        case .rename: return "Specific.Rename"
        }
    }
}

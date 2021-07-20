import Foundation

extension ContextualMenu {
    var title: String {
        resourceKey.localized
    }
    
    private var resourceKey: String {
        switch self {
        case .addBlockBelow: return "General.AddBlockBelow"
        case .delete: return "General.Delete"
        case .duplicate: return "General.Duplicate"
        case .turnIntoPage: return "Specific.TurnIntoPage"
        case .style: return "Specific.Style"
        case .download: return "Specific.Download"
        case .replace: return "Specific.Replace"
        }
    }
}

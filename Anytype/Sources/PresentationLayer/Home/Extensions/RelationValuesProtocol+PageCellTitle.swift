import Foundation
import BlocksModels

extension BundledRelationsValueProvider {
    
    var pageCellTitle: HomeCellData.Title {
        switch layout {
        case .note:
            return .default(title: snippet)
        case .todo:
            return .todo(title: name, isChecked: isDone)
        default:
            return .default(title: name)
        }
    }

    var title: String {
        if isDeleted {
            return "Non-existent object".localized
        }
        
        let title: String

        switch layout {
        case .note:
            title = snippet
        default:
            title = name
        }

        return title.isEmpty ? "Untitled".localized : title
    }
    
    var mentionTitle: String {
        String(title.prefix(30)).replacingOccurrences(of: "\n", with: " ")
    }
}

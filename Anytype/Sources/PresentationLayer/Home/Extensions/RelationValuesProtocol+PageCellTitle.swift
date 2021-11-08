import Foundation
import BlocksModels

extension RelationValuesProvider {
    
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
        let title: String

        switch layout {
        case .note:
            title =  snippet
        default:
            title = name
        }

        return title.isEmpty ? "Untitled".localized : title
    }
}

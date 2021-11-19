import Foundation
import UIKit
import Combine
import BlocksModels

struct HomeCellData: Identifiable {
    let id: String
    let destinationId: String
    let icon: ObjectIconType?
    let title: Title
    let type: String
    let isLoading: Bool
    let isArchived: Bool
    let isDeleted: Bool
    let viewType: EditorViewType
    
    var selected: Bool
    
    static func create(searchResult: SearchData) -> HomeCellData {
        HomeCellData(
            id: searchResult.id,
            destinationId: searchResult.id,
            icon: searchResult.icon,
            title: searchResult.pageCellTitle,
            type: searchResult.objectType.name,
            isLoading: false,
            isArchived: searchResult.isArchived,
            isDeleted: searchResult.isDeleted,
            viewType: searchResult.editorViewType,
            selected: false
        )
    }
}

extension HomeCellData {
    
    enum Title {
        case `default`(title: String)
        case todo(title: String, isChecked: Bool)
        
        var isTodo: Bool {
            switch self {
            case .todo:
                return true
            default:
                return false
            }
        }
    }
    
}

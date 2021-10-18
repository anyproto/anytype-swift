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
    
    let selected: Bool
    
    static func create(searchResult: ObjectDetails) -> HomeCellData {
        HomeCellData(
            id: searchResult.id,
            destinationId: searchResult.id,
            icon: searchResult.icon,
            title: searchResult.pageCellTitle,
            type: searchResult.objectType?.name ?? "Page".localized,
            isLoading: false,
            isArchived: searchResult.isArchived,
            selected: false
        )
    }
    
    func withSelected(_ selected: Bool) -> Self {
        if self.selected == selected { return self }
        
        return HomeCellData(
            id: id, destinationId: destinationId, icon: icon,
            title: title, type: type, isLoading: isLoading, isArchived: isArchived,
            selected: selected
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

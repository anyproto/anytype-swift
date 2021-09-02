import Foundation
import UIKit
import Combine


struct HomeCellData: Identifiable {
    let id: String
    let destinationId: String
    let icon: ObjectIconType?
    let title: Title
    let type: String
    let isLoading: Bool
    let isArchived: Bool
    
    static func create(searchResult: SearchResult) -> HomeCellData {
        HomeCellData(
            id: searchResult.id,
            destinationId: searchResult.id,
            icon: searchResult.icon,
            title: searchResult.pageCellTitle,
            type: searchResult.type?.name ?? "Page".localized,
            isLoading: false,
            isArchived: searchResult.isArchived ?? false
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

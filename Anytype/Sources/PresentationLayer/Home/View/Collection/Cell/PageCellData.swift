import Foundation
import UIKit
import Combine


struct PageCellData: Identifiable {
    let id: String
    let destinationId: String
    let icon: DocumentIconType?
    let title: String
    let type: String
    let isLoading: Bool
    let isArchived: Bool
    
    static func create(searchResult: SearchResult) -> PageCellData {
        PageCellData(
            id: searchResult.id,
            destinationId: searchResult.id,
            icon: searchResult.icon,
            title: searchResult.name ?? "",
            type: searchResult.type?.name ?? "Page",
            isLoading: false,
            isArchived: searchResult.isArchived ?? false
        )
    }
}


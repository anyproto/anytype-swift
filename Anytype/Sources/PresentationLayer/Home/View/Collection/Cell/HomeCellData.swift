import Foundation
import UIKit
import Combine
import BlocksModels
import AnytypeCore

struct HomeCellData: Identifiable, IdProvider {
    let id: BlockId
    let destinationId: BlockId
    let icon: ObjectIconImage?
    let title: String
    let titleLayout: TitleLayout
    let type: String
    let isLoading: Bool
    let isArchived: Bool
    let isDeleted: Bool
    let isFavorite: Bool
    let viewType: EditorViewType
    
    static func create(details: ObjectDetails) -> HomeCellData {
        HomeCellData(
            id: details.id,
            destinationId: details.id,
            icon: details.objectIconImage,
            title: details.pageCellTitle,
            titleLayout: details.homeLayout,
            type: details.objectType.name,
            isLoading: false,
            isArchived: details.isArchived,
            isDeleted: details.isDeleted,
            isFavorite: details.isFavorite,
            viewType: details.editorViewType
        )
    }
}

extension HomeCellData {
    
    enum TitleLayout {
        case horizontal
        case vertical
    }
}

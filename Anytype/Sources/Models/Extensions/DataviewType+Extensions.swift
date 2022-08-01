import Foundation
import BlocksModels

extension DataviewViewType {
    var name: String {
        switch self {
        case .table:
            return Loc.DataviewType.table
        case .list:
            return Loc.DataviewType.list
        case .gallery:
            return Loc.DataviewType.gallery
        case .kanban:
            return Loc.DataviewType.kanban
        }
    }
}

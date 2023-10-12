import Foundation
import Services
import AnytypeCore

extension DataviewViewType {
    var name: String {
        switch self {
        case .table:
            return Loc.DataviewType.grid
        case .list:
            return Loc.DataviewType.list
        case .gallery:
            return Loc.DataviewType.gallery
        case .kanban:
            return Loc.DataviewType.kanban
        }
    }
    
    func icon(selected: Bool) -> ImageAsset {
        switch self {
        case .table:
            return selected ? .X54.View.gridSelected : .X54.View.grid
        case .list:
            return selected ? .X54.View.listSelected : .X54.View.list
        case .gallery:
            return selected ? .X54.View.gallerySelected : .X54.View.gallery
        case .kanban:
            return selected ? .X54.View.kanbanSelected : .X54.View.kanban
        }
    }
    
    var iconLecacy: ImageAsset {
        switch self {
        case .table:
            return .X24.View.table
        case .list:
            return .X24.View.list
        case .gallery:
            return .X24.View.gallery
        case .kanban:
            return .X24.View.kanban
        }
    }
    
    var setContentViewType: SetContentViewType {
        switch self {
        case .table:
            return .table
        case .gallery:
            return .collection(.gallery)
        case .list:
            return .collection(.list)
        case .kanban:
            return FeatureFlags.setKanbanView ? .kanban : .table
        }
    }
    
    var settings: [SetLayoutSettings] {
        switch setContentViewType {
        case let .collection(type):
            switch type {
            case .gallery:
                return [.icon, .cardSize, .imagePreview, .fitImage]
            case .list:
                return [.icon]
            }
        case .table:
            return [.icon]
        case .kanban:
            return [.icon, .groupBy, .colorColumns]
        }
    }
}

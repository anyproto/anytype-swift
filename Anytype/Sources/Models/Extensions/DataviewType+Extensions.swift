import Foundation
import BlocksModels
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
    
    var icon: ImageAsset {
        switch self {
        case .table:
            return .setGridView
        case .list:
            return .setListView
        case .gallery:
            return .setGalleryView
        case .kanban:
            return .setKanbanView
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
    
    var isSupported: Bool {
        self == .table ||
        self == .gallery ||
        self == .list ||
        (FeatureFlags.setKanbanView && self == .kanban)
    }
}

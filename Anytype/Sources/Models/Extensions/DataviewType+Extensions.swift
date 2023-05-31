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
    
    var icon: ImageAsset {
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
    
    var isSupported: Bool {
        self == .table ||
        self == .gallery ||
        self == .list ||
        (FeatureFlags.setKanbanView && self == .kanban)
    }
}

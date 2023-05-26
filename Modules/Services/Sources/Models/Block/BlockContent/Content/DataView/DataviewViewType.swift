import AnytypeCore

public enum DataviewViewType: Hashable, CaseIterable {
    case table
    case gallery
    case list
    case kanban
    
    public var asMiddleware: DataviewTypeEnum {
        switch self {
        case .table:
            return .table
        case .list:
            return .list
        case .gallery:
            return .gallery
        case .kanban:
            return .kanban
        }
    }
    
    public var hasGroups: Bool {
        switch self {
        case .kanban:
            return FeatureFlags.setKanbanView
        case .list, .gallery, .table:
            return false
        }
    }
    
    public var stringValue: String {
        switch self {
        case .table: return "Grid"
        case .list: return "List"
        case .gallery: return "Gallery"
        case .kanban: return "Board"
        }
    }
}

public extension DataviewTypeEnum {
    var asModel: DataviewViewType? {
        switch self {
        case .table: return .table
        case .list: return .list
        case .gallery: return .gallery
        case .kanban: return .kanban
        case .UNRECOGNIZED: return nil
        }
    }
}

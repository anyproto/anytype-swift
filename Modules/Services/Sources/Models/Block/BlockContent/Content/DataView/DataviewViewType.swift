import AnytypeCore

public enum DataviewViewType: Hashable, CaseIterable, Sendable {
    case table
    case gallery
    case list
    case kanban
    case calendar
    case graph
    
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
        case .calendar:
            return .calendar
        case .graph:
            return .graph
        }
    }
    
    public var hasGroups: Bool {
        switch self {
        case .kanban:
            return FeatureFlags.setKanbanView
        case .list, .gallery, .table, .calendar, .graph:
            return false
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
        case .calendar: return .calendar
        case .graph: return .graph
        case .UNRECOGNIZED: return nil
        }
    }
}

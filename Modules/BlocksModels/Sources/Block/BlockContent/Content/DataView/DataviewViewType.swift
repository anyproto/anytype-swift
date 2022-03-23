public enum DataviewViewType: Hashable {
    case table
    case list
    case gallery
    case kanban
    
    public var name: String {
        switch self {
        case .table:
            return "table".localized
        case .list:
            return "list".localized
        case .gallery:
            return "gallery".localized
        case .kanban:
            return "kanban".localized
        }
    }
    
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

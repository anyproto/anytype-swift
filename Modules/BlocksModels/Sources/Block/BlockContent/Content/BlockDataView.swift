import AnytypeCore
import ProtobufMessages

public typealias DataviewSort = Anytype_Model_Block.Content.Dataview.Sort
public typealias DataviewFilter = Anytype_Model_Block.Content.Dataview.Filter

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
}

public struct DataviewViewRelation: Hashable {
    public let key: String
    public let isVisible: Bool
    
    public init(key: String, isVisible: Bool) {
        self.key = key
        self.isVisible = isVisible
    }
}

public struct DataviewView: Hashable, Identifiable {
    public let id: BlockId
    public let name: String

    public let type: DataviewViewType
    
    public let relations: [DataviewViewRelation]
    public let sorts: [DataviewSort]
    public let filters: [DataviewFilter]

    public init(
        id: BlockId,
        name: String,
        type: DataviewViewType,
        relations: [DataviewViewRelation],
        sorts: [DataviewSort],
        filters: [DataviewFilter]
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.relations = relations
        self.sorts = sorts
        self.filters = filters
    }
    
    public static var empty: DataviewView {
        DataviewView(id: "", name: "", type: .list, relations: [], sorts: [], filters: [])
    }
    
    public var isSupported: Bool {
        type == .table
    }
}


public struct BlockDataview: Hashable {
    public let source: [String]
    public let views: [DataviewView]
    public let relations: [RelationMetadata]
    
    public init(
        source: [String],
        views: [DataviewView],
        relations: [RelationMetadata]
    ) {
        self.source = source
        self.views = views
        self.relations = relations
    }
    
    public static var empty: BlockDataview {
        BlockDataview(source: [], views: [], relations: [])
    }
}


extension BlockDataview {
    public func relationsMetadataForView(_ view: DataviewView) -> [RelationMetadata] {
        return view.relations
            .filter { $0.isVisible }
            .map(\.key)
            .compactMap { key in
                relations.first { $0.key == key }
            }
    }
}

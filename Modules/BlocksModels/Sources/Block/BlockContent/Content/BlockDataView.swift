public enum DataviewViewType: Hashable {
    case table
    case list
    case gallery
    case kanban
}


public struct DataviewView: Hashable {
    public let id: BlockId
    public let name: String

    public let type: DataviewViewType

    public init(
        id: BlockId,
        name: String,
        type: DataviewViewType
    ) {
        self.id = id
        self.name = name
        self.type = type
    }
}


public struct BlockDataview: Hashable {
    public let source: [String]
    public let activeViewId: BlockId
    public let views: [DataviewView]
    
    public var activeView: DataviewView? {
        views.first { $0.id == activeViewId } ?? views.first
    }
    
    public init(
        source: [String],
        activeView: BlockId,
        views: [DataviewView]
    ) {
        self.source = source
        self.activeViewId = activeView
        self.views = views
    }
}

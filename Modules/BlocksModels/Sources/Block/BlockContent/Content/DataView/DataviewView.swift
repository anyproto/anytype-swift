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

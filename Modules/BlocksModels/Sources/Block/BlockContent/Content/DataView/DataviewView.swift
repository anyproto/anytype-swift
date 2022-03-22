import ProtobufMessages

public struct DataviewView: Hashable, Identifiable {
    public let id: BlockId
    public let name: String

    public let type: DataviewViewType
    
    public let relations: [DataviewViewRelation]
    public let sorts: [DataviewSort]
    public let filters: [DataviewFilter]
    
    public let coverRelationKey: String
    public let hideIcon: Bool
    public let cardSize: DataviewViewSize
    public let coverFit: Bool
    
    public static var empty: DataviewView {
        DataviewView(
            id: "",
            name: "",
            type: .table,
            relations: [],
            sorts: [],
            filters: [],
            coverRelationKey: "",
            hideIcon: false,
            cardSize: .small,
            coverFit: false
        )
    }
    
    public var isSupported: Bool {
        type == .table
    }
    
    public var asMiddleware: MiddlewareDataviewView {
        MiddlewareDataviewView(
            id: id,
            type: type.asMiddleware,
            name: name,
            sorts: sorts,
            filters: filters,
            relations: relations.map(\.asMiddleware),
            coverRelationKey: coverRelationKey,
            hideIcon: hideIcon,
            cardSize: cardSize,
            coverFit: coverFit
        )
    }
}

public extension DataviewView {
    init?(data: MiddlewareDataviewView) {
        guard let type = data.type.asModel else { return nil }
        
        self.id = data.id
        self.name = data.name
        self.type = type
        self.relations = data.relations.map(\.asModel)
        self.sorts = data.sorts
        self.filters = data.filters
        self.coverRelationKey = data.coverRelationKey
        self.hideIcon = data.hideIcon
        self.cardSize = data.cardSize
        self.coverFit = data.coverFit
    }
}

public extension MiddlewareDataviewView {
    var asModel: DataviewView? {
        DataviewView(data: self)
    }
}

import ProtobufMessages

public struct DataviewView: Hashable, Identifiable {
    public let id: BlockId
    public let name: String

    public let type: DataviewViewType
    
    public let options: [DataviewRelationOption]
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
            options: [],
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
    
    public func updated(
        hideIcon: Bool? = nil,
        coverFit: Bool? = nil,
        cardSize: DataviewViewSize? = nil,
        options: [DataviewRelationOption]? = nil,
        sorts: [DataviewSort]? = nil,
        filters: [DataviewFilter]? = nil
    ) -> DataviewView {
        DataviewView(
            id: id,
            name: name,
            type: type,
            options: options ?? self.options,
            sorts: sorts ?? self.sorts,
            filters: filters ?? self.filters,
            coverRelationKey: coverRelationKey,
            hideIcon: hideIcon ?? self.hideIcon,
            cardSize: cardSize ?? self.cardSize,
            coverFit: coverFit ?? self.coverFit
        )
    }
    
    public func updated(option: DataviewRelationOption) -> DataviewView {
        var newOptions = options
        
        if let index = newOptions
            .firstIndex(where: { $0.key == option.key }) {
            newOptions[index] = option
        } else {
            newOptions.append(option)
        }
        
        return updated(options: newOptions)
    }
    
    public var asMiddleware: MiddlewareDataviewView {
        MiddlewareDataviewView(
            id: id,
            type: type.asMiddleware,
            name: name,
            sorts: sorts,
            filters: filters,
            relations: options.map(\.asMiddleware),
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
        self.options = data.relations.map(\.asModel)
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

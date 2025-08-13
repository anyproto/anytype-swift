import ProtobufMessages
import AnytypeCore

public struct DataviewView: Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String

    public let type: DataviewViewType
    
    public let options: [DataviewRelationOption]
    public let sorts: [DataviewSort]
    public let filters: [DataviewFilter]
    
    public let coverRelationKey: String
    public let hideIcon: Bool
    public let cardSize: DataviewViewSize
    public let coverFit: Bool
    public let groupRelationKey: String
    public let groupBackgroundColors: Bool
    public let defaultTemplateID: String?
    public let defaultObjectTypeID: String?
    
    public static var empty: DataviewView {
        DataviewView(
            id: "",
            name: "",
            type: .list,
            options: [],
            sorts: [],
            filters: [],
            coverRelationKey: "",
            hideIcon: false,
            cardSize: .small,
            coverFit: false,
            groupRelationKey: "",
            groupBackgroundColors: false,
            defaultTemplateID: nil,
            defaultObjectTypeID: nil
        )
    }
    
    public func updated(
        name: String? = nil,
        type: DataviewViewType? = nil,
        cardSize: DataviewViewSize? = nil,
        hideIcon: Bool? = nil,
        coverRelationKey: String? = nil,
        coverFit: Bool? = nil,
        options: [DataviewRelationOption]? = nil,
        sorts: [DataviewSort]? = nil,
        filters: [DataviewFilter]? = nil,
        groupRelationKey: String?  = nil,
        groupBackgroundColors: Bool? = nil,
        defaultTemplateID: String? = nil,
        defaultObjectTypeID: String? = nil
    ) -> DataviewView {
        DataviewView(
            id: id,
            name: name ?? self.name,
            type: type ?? self.type,
            options: options ?? self.options,
            sorts: sorts ?? self.sorts,
            filters: filters ?? self.filters,
            coverRelationKey: coverRelationKey ?? self.coverRelationKey,
            hideIcon: hideIcon ?? self.hideIcon,
            cardSize: cardSize ?? self.cardSize,
            coverFit: coverFit ?? self.coverFit,
            groupRelationKey: groupRelationKey ?? self.groupRelationKey,
            groupBackgroundColors: groupBackgroundColors ?? self.groupBackgroundColors,
            defaultTemplateID: defaultTemplateID ?? self.defaultTemplateID,
            defaultObjectTypeID: defaultObjectTypeID ?? self.defaultObjectTypeID
        )
    }
    
    public func updated(with fields: DataviewViewUpdateFields) -> DataviewView {
        DataviewView(
            id: id,
            name: fields.name,
            type: fields.type.asModel ?? self.type,
            options: self.options,
            sorts: self.sorts,
            filters: self.filters,
            coverRelationKey: fields.coverRelationKey,
            hideIcon: fields.hideIcon,
            cardSize: fields.cardSize,
            coverFit: fields.coverFit,
            groupRelationKey: fields.groupRelationKey,
            groupBackgroundColors: fields.groupBackgroundColors,
            defaultTemplateID: fields.defaultTemplateID,
            defaultObjectTypeID: fields.defaultObjectTypeID
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
        MiddlewareDataviewView.with {
            $0.id = id
            $0.type = type.asMiddleware
            $0.name = name
            $0.sorts = sorts
            $0.filters = filters
            $0.relations = options.map(\.asMiddleware)
            $0.coverRelationKey = coverRelationKey
            $0.hideIcon = hideIcon
            $0.cardSize = cardSize
            $0.coverFit = coverFit
            $0.groupRelationKey = groupRelationKey
            $0.groupBackgroundColors = groupBackgroundColors
            $0.defaultTemplateID = defaultTemplateID ?? ""
            $0.defaultObjectTypeID = defaultObjectTypeID ?? ""
        }
    }
    
    public var canSwitchItemName: Bool {
        type == .gallery
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
        self.groupRelationKey = data.groupRelationKey
        self.groupBackgroundColors = data.groupBackgroundColors
        self.defaultTemplateID = data.defaultTemplateID.isEmpty ? nil : data.defaultTemplateID
        self.defaultObjectTypeID = data.defaultObjectTypeID.isEmpty ? nil : data.defaultObjectTypeID
    }
}

public extension MiddlewareDataviewView {
    var asModel: DataviewView? {
        DataviewView(data: self)
    }
}

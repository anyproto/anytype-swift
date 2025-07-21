public struct DataviewRelationOption: Hashable, Sendable {
    public let key: String
    public let isVisible: Bool
    public let width: Int32
    public let relationFormatIncludeTime: Bool
    public let timeFormat: DataviewTimeFormat
    public let dateFormat: DataviewDateFormat
    
    public var asMiddleware: MiddlewareRelation {
        MiddlewareRelation.with {
            $0.key = key
            $0.isVisible = isVisible
            $0.width = width
            $0.relationFormatIncludeTime = relationFormatIncludeTime
            $0.timeFormat = timeFormat
            $0.dateFormat = dateFormat
        }
    }
    
    public func updated(isVisible: Bool) -> DataviewRelationOption {
        DataviewRelationOption(
            key: key,
            isVisible: isVisible,
            width: width,
            relationFormatIncludeTime: relationFormatIncludeTime,
            timeFormat: timeFormat,
            dateFormat: dateFormat
        )
    }
}
            
public extension DataviewRelationOption {
    init(data: MiddlewareRelation) {
        self.key = data.key
        self.isVisible = data.isVisible
        self.width = data.width
        self.relationFormatIncludeTime = data.relationFormatIncludeTime
        self.timeFormat = data.timeFormat
        self.dateFormat = data.dateFormat
    }
    
    init(key: String, isVisible: Bool) {
        self.init(
            key: key,
            isVisible: isVisible,
            width: 0,
            relationFormatIncludeTime: false,
            timeFormat: .format12,
            dateFormat: .monthAbbrBeforeDay
        )
    }
}

public extension MiddlewareRelation {
    var asModel: DataviewRelationOption {
        DataviewRelationOption(data: self)
    }
}

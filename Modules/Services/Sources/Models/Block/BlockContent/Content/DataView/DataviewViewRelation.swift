public struct DataviewRelationOption: Hashable {
    public let key: String
    public let isVisible: Bool
    public let width: Int32
    public let dateIncludeTime: Bool
    public let timeFormat: DataviewTimeFormat
    public let dateFormat: DataviewDateFormat
    
    public var asMiddleware: MiddlewareRelation {
        MiddlewareRelation.with {
            $0.key = key
            $0.isVisible = isVisible
            $0.width = width
            $0.dateIncludeTime = dateIncludeTime
            $0.timeFormat = timeFormat
            $0.dateFormat = dateFormat
        }
    }
    
    public func updated(isVisible: Bool) -> DataviewRelationOption {
        DataviewRelationOption(
            key: key,
            isVisible: isVisible,
            width: width,
            dateIncludeTime: dateIncludeTime,
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
        self.dateIncludeTime = data.dateIncludeTime
        self.timeFormat = data.timeFormat
        self.dateFormat = data.dateFormat
    }
    
    init(key: BlockId, isVisible: Bool) {
        self.init(
            key: key,
            isVisible: isVisible,
            width: 0,
            dateIncludeTime: false,
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

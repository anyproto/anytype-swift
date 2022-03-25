public struct DataviewRelation: Hashable {
    public let key: String
    public let isVisible: Bool
    public let width: Int32
    public let dateIncludeTime: Bool
    public let timeFormat: DataviewTimeFormat
    public let dateFormat: DataviewDateFormat
    
    public var asMiddleware: MiddlewareRelation {
        MiddlewareRelation(
            key: key,
            isVisible: isVisible,
            width: width,
            dateIncludeTime: dateIncludeTime,
            timeFormat: timeFormat,
            dateFormat: dateFormat
        )
    }
    
    public func updated(isVisible: Bool) -> DataviewRelation {
        DataviewRelation(
            key: key,
            isVisible: isVisible,
            width: width,
            dateIncludeTime: dateIncludeTime,
            timeFormat: timeFormat,
            dateFormat: dateFormat
        )
    }
}
            
public extension DataviewRelation {
    init(data: MiddlewareRelation) {
        self.key = data.key
        self.isVisible = data.isVisible
        self.width = data.width
        self.dateIncludeTime = data.dateIncludeTime
        self.timeFormat = data.timeFormat
        self.dateFormat = data.dateFormat
    }
}

public extension MiddlewareRelation {
    var asModel: DataviewRelation {
        DataviewRelation(data: self)
    }
}

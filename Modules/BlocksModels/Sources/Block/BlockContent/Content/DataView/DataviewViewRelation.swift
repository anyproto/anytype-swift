public struct DataviewViewRelation: Hashable {
    public let key: String
    public let isVisible: Bool
    public let width: Int32
    public let dateIncludeTime: Bool
    public let timeFormat: DataviewTimeFormat
    public let dateFormat: DataviewDateFormat
    
    public init(data: DataviewRelation) {
        self.key = data.key
        self.isVisible = data.isVisible
        self.width = data.width
        self.dateIncludeTime = data.dateIncludeTime
        self.timeFormat = data.timeFormat
        self.dateFormat = data.dateFormat
    }
    
    var asMiddleware: DataviewRelation {
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
    var asModel: DataviewViewRelation {
        DataviewViewRelation(data: self)
    }
}

public struct DataviewViewRelation: Hashable {
    public let key: String
    public let isVisible: Bool
    
    public init(key: String, isVisible: Bool) {
        self.key = key
        self.isVisible = isVisible
    }
}

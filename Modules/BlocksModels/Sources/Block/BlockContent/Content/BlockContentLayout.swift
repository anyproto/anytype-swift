public struct BlockLayout: Hashable {
    public enum Style {
        case row
        case column
        case div
        case header
    }
    
    public var style: Style
    // MARK: - Memberwise initializer
    public init(style: Style) {
        self.style = style
    }
}

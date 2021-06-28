public struct BlockDivider: Hashable {
    public enum Style {
        case line
        case dots
    }
    
    public var style: Style
    // MARK: - Memberwise initializer
    public init(style: Style) {
        self.style = style
    }
}

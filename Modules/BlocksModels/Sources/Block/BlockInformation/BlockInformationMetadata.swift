public enum BlockIndentationStyle: Hashable {
    case `none`
    case highlighted
    case callout
}

public struct BlockInformationMetadata: Hashable {
    public let parentId: BlockId?
    public let parentBackgroundColors: [MiddlewareColor?]
    public let parentIndentationStyle: [BlockIndentationStyle]
    public let backgroundColor: MiddlewareColor?
    public let indentationStyle: BlockIndentationStyle

    public init(
        parentId: BlockId? = nil,
        parentBackgroundColors: [MiddlewareColor?] = [MiddlewareColor](),
        parentIndentationStyle: [BlockIndentationStyle] = [BlockIndentationStyle](),
        backgroundColor: MiddlewareColor?,
        indentationStyle: BlockIndentationStyle
    ) {
        self.parentId = parentId
        self.parentBackgroundColors = parentBackgroundColors
        self.parentIndentationStyle = parentIndentationStyle
        self.backgroundColor = backgroundColor
        self.indentationStyle = indentationStyle
    }
}

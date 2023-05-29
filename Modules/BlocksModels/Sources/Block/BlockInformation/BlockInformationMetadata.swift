public enum BlockIndentationStyle: Hashable {
    public enum HighligtedStyle {
        case full
        case closing
        case single
    }

    case `none`
    case highlighted(HighligtedStyle)
    case callout
}

public struct BlockInformationMetadata: Hashable {
    public let parentId: BlockId?
    public let parentBackgroundColors: [MiddlewareColor?]
    public let parentIndentationStyle: [BlockIndentationStyle]
    public let backgroundColor: MiddlewareColor?
    public let indentationStyle: BlockIndentationStyle
    public let calloutBackgroundColor: MiddlewareColor?

    public init(
        parentId: BlockId? = nil,
        parentBackgroundColors: [MiddlewareColor?] = [MiddlewareColor](),
        parentIndentationStyle: [BlockIndentationStyle] = [BlockIndentationStyle](),
        backgroundColor: MiddlewareColor?,
        indentationStyle: BlockIndentationStyle,
        calloutBackgroundColor: MiddlewareColor?
    ) {
        self.parentId = parentId
        self.parentBackgroundColors = parentBackgroundColors
        self.parentIndentationStyle = parentIndentationStyle
        self.backgroundColor = backgroundColor
        self.indentationStyle = indentationStyle
        self.calloutBackgroundColor = calloutBackgroundColor
    }
}

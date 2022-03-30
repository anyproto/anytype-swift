public struct BlockInformationMetadata: Hashable {
    public let indentationLevel: Int
    public let parentId: BlockId?
    public let parentBackgroundColors: [MiddlewareColor?]

    public init(
        indentationLevel: Int = 0,
        parentId: BlockId? = nil,
        parentBackgroundColors: [MiddlewareColor?] = []
    ) {
        self.indentationLevel = indentationLevel
        self.parentId = parentId
        self.parentBackgroundColors = parentBackgroundColors
    }
}

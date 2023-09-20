public struct BlockInformationMetadata: Hashable {
    public let parentId: BlockId?
    public let backgroundColor: MiddlewareColor?

    public init(parentId: BlockId? = nil, backgroundColor: MiddlewareColor?) {
        self.parentId = parentId
        self.backgroundColor = backgroundColor
    }
}

public struct BlockInformationMetadata: Hashable, Sendable {
    public let parentId: String?
    public let backgroundColor: MiddlewareColor?

    public init(parentId: String? = nil, backgroundColor: MiddlewareColor?) {
        self.parentId = parentId
        self.backgroundColor = backgroundColor
    }
}

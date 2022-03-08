public struct BlockInformationMetadata: Hashable {
    public let indentationLevel: Int
    public let parentId: BlockId?
    
    public init(indentationLevel: Int = 0, parentId: BlockId? = nil) {
        self.indentationLevel = indentationLevel
        self.parentId = parentId
    }
}

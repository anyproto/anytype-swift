public final class BlockInformationMetadata: Hashable {
    public var indentationLevel: Int = 0
    public var parent: BlockInformation?
    
    
    // MARK: - Hashable
    public static func == (lhs: BlockInformationMetadata, rhs: BlockInformationMetadata) -> Bool {
        lhs.indentationLevel == rhs.indentationLevel && lhs.parent == rhs.parent
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(indentationLevel)
        hasher.combine(parent)
    }
}

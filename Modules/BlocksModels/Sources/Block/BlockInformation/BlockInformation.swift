import ProtobufMessages

public struct BlockInformation: Hashable {
    public var id: BlockId
    public var content: BlockContent
    
    public var childrenIds = [BlockId]()
    
    public var fields = [String: BlockFieldType]()
    
    public var backgroundColor = ""
    public var alignment = LayoutAlignment.left
    
    public init(id: BlockId, content: BlockContent) {
        self.id = id
        self.content = content
    }

    public static func == (lhs: BlockInformation, rhs: BlockInformation) -> Bool {
        lhs.id == rhs.id
    }

    // TODO: Remove
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

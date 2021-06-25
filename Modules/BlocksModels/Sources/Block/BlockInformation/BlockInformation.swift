import ProtobufMessages

public enum BlockInformationAlignment: CaseIterable, Hashable {
    case left
    case center
    case right
}

public struct BlockInformation: Hashable {
    public var id: BlockId
    public var content: BlockContent
    
    public var childrenIds = [BlockId]()
    
    public var fields = [String: BlockFieldType]()
    
    public var backgroundColor = ""
    public var alignment = BlockInformationAlignment.left
    
    public init(id: BlockId, content: BlockContent) {
        self.id = id
        self.content = content
    }

    public static func == (lhs: BlockInformation, rhs: BlockInformation) -> Bool {
        lhs.id == rhs.id && lhs.content.type == rhs.content.type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(content.type)
    }
}

import ProtobufMessages

public enum BlockInformationAlignment: CaseIterable, Hashable {
    case left, center, right
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
}

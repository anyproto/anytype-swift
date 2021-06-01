import ProtobufMessages

public enum BlockInformationAlignment: CaseIterable, Hashable {
    case left, center, right
}

public struct BlockInformationModel: Hashable {
    public typealias ChildrenIds = [BlockId]

    public var id: BlockId
    public var childrenIds: ChildrenIds = []
    public var content: BlockContent
    
    public var fields: [String: BlockFieldType] = [:]
    var restrictions: [String] = []
    
    public var backgroundColor = ""
    public var alignment: BlockInformationAlignment = .left
            
    static func defaultValue() -> Self { .default }
    
    public init(id: BlockId, content: BlockContent) {
        self.id = id
        self.content = content
    }
    
    public init(information: Self) {
        self.id = information.id
        self.content = information.content
        self.childrenIds = information.childrenIds
        
        self.fields = information.fields
        self.restrictions = information.restrictions
        
        self.backgroundColor = information.backgroundColor
        self.alignment = information.alignment
    }
    
    private static let `defaultId`: BlockId = "DefaultIdentifier"
    private static let `defaultBlockType`: BlockContent = .text(.createDefault(text: "DefaultText"))
    private static let `default`: Self = .init(id: Self.defaultId, content: Self.defaultBlockType)
}

public enum BlockInformation {
}

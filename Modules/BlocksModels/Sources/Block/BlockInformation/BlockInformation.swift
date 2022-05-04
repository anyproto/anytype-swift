import ProtobufMessages

public struct BlockInformation: Hashable {
    public let id: BlockId
    public let content: BlockContent
    
    public let childrenIds: [BlockId]
    
    public let fields: MiddleBlockFields
    
    public let backgroundColor: MiddlewareColor?
    public let alignment: LayoutAlignment
    
    public let metadata: BlockInformationMetadata
    
    public init(
        id: BlockId,
        content: BlockContent,
        backgroundColor: MiddlewareColor?,
        alignment: LayoutAlignment,
        childrenIds: [BlockId],
        fields: MiddleBlockFields,
        metadata: BlockInformationMetadata
    ) {
        self.id = id
        self.content = content
        self.backgroundColor = backgroundColor
        self.alignment = alignment
        self.childrenIds = childrenIds
        self.fields = fields
        self.metadata = metadata
    }
}

public enum FieldName {
    public static let codeLanguage = "lang"
}

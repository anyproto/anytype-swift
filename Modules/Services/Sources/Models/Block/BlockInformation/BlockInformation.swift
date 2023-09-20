import AnytypeCore

public struct BlockInformation: Hashable {
    public let id: BlockId
    public let content: BlockContent
    
    public let childrenIds: [BlockId]
    
    public let fields: BlockFields
    
    public let backgroundColor: MiddlewareColor?
    public let horizontalAlignment: LayoutAlignment
    public let configurationData: BlockInformationMetadata
    
    public init(
        id: BlockId,
        content: BlockContent,
        backgroundColor: MiddlewareColor?,
        horizontalAlignment: LayoutAlignment,
        childrenIds: [BlockId],
        configurationData: BlockInformationMetadata,
        fields: BlockFields
    ) {
        self.id = id
        self.content = content
        self.backgroundColor = backgroundColor
        self.horizontalAlignment = horizontalAlignment
        self.childrenIds = childrenIds
        self.fields = fields
        self.configurationData = configurationData
    }
}

import AnytypeCore

public struct BlockInformation: Hashable {
    public let id: AnytypeId
    public let content: BlockContent
    
    public let childrenIds: [AnytypeId]
    
    public let fields: BlockFields
    
    public let backgroundColor: MiddlewareColor?
    public let alignment: LayoutAlignment
    
    public let configurationData: BlockInformationMetadata
    
    public init(
        id: AnytypeId,
        content: BlockContent,
        backgroundColor: MiddlewareColor?,
        alignment: LayoutAlignment,
        childrenIds: [AnytypeId],
        configurationData: BlockInformationMetadata,
        fields: BlockFields
    ) {
        self.id = id
        self.content = content
        self.backgroundColor = backgroundColor
        self.alignment = alignment
        self.childrenIds = childrenIds
        self.fields = fields
        self.configurationData = configurationData
    }
}

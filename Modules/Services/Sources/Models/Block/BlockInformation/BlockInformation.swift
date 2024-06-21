import AnytypeCore

public struct BlockInformation: Hashable, Sendable {
    public let id: String
    public let content: BlockContent
    
    public let childrenIds: [String]
    
    public let fields: BlockFields
    
    public let backgroundColor: MiddlewareColor?
    public let horizontalAlignment: LayoutAlignment
    public let configurationData: BlockInformationMetadata
    
    public init(
        id: String,
        content: BlockContent,
        backgroundColor: MiddlewareColor?,
        horizontalAlignment: LayoutAlignment,
        childrenIds: [String],
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

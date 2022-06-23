import AnytypeCore

public extension BlockInformation {
    
    func updated(
        content: BlockContent? = nil,
        backgroundColor: MiddlewareColor? = nil,
        horizontalAlignment: LayoutAlignment? = nil,
        childrenIds: [BlockId]? = nil,
        fields: BlockFields? = nil,
        metadata: BlockInformationMetadata? = nil
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content ?? self.content,
            backgroundColor: backgroundColor ?? self.backgroundColor,
            horizontalAlignment: horizontalAlignment ?? self.horizontalAlignment,
            childrenIds: childrenIds ?? self.childrenIds,
            configurationData: metadata ?? self.configurationData,
            fields: fields ?? self.fields
        )
    }
    
}

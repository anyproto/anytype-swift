import AnytypeCore

public extension BlockInformation {
    
    func updated(
        content: BlockContent? = nil,
        backgroundColor: MiddlewareColor? = nil,
        alignment: LayoutAlignment? = nil,
        childrenIds: [AnytypeId]? = nil,
        fields: BlockFields? = nil,
        metadata: BlockInformationMetadata? = nil
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content ?? self.content,
            backgroundColor: backgroundColor ?? self.backgroundColor,
            alignment: alignment ?? self.alignment,
            childrenIds: childrenIds ?? self.childrenIds,
            configurationData: metadata ?? self.configurationData,
            fields: fields ?? self.fields
        )
    }
    
}

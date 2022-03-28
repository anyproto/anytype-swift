public extension BlockInformation {
    func updated(
        content: BlockContent? = nil,
        backgroundColor: MiddlewareColor? = nil,
        alignment: LayoutAlignment? = nil,
        childrenIds: [BlockId]? = nil,
        fields: BlockFields? = nil,
        metadata: BlockInformationMetadata? = nil
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content ?? self.content,
            backgroundColor: backgroundColor ?? self.backgroundColor,
            alignment: alignment ?? self.alignment,
            childrenIds: childrenIds ?? self.childrenIds,
            fields: fields ?? self.fields,
            configurationData: metadata ?? self.configurationData
        )
    }
}

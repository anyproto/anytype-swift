public extension BlockInformation {
    func updated(with backgroundColor: MiddlewareColor?) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields,
            metadata: metadata
        )
    }
    
    func updated(with fields: BlockFields) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields,
            metadata: metadata
        )
    }
    
    func updated(with alignment: LayoutAlignment) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields,
            metadata: metadata
        )
    }
    
    func updated(with childrenIds: [BlockId]) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields,
            metadata: metadata
        )
    }
    
    func updated(with content: BlockContent) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields,
            metadata: metadata
        )
    }
    
    func updated(with metadata: BlockInformationMetadata) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: childrenIds,
            fields: fields,
            metadata: metadata
        )
    }
}

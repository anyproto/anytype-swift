public extension BlockInformation {
    static var emptyText: BlockInformation {
        empty(content: .text(.empty(contentType: .text)))
    }
    
    static func empty(
        id: BlockId = "", content: BlockContent
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: nil,
            alignment: .left,
            childrenIds: [],
            fields: [:],
            metadata: BlockInformationMetadata(
                backgroundColor: .default,
                indentationStyle: .none
            )
        )
    }
    
    static func emptyLink(targetId: BlockId) -> BlockInformation {
        let content: BlockContent = .link(BlockLink(targetBlockID: targetId, style: .page, fields: [:]))
        return BlockInformation.empty(content: content)
    }
}

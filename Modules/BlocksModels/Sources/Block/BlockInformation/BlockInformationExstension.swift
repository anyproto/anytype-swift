public extension BlockInformation {
    static var emptyText: BlockInformation {
        empty(content: .text(.empty))
    }
    
    static func empty(
        blockId: BlockId = "", content: BlockContent
    ) -> BlockInformation {
        BlockInformation(
            id: blockId,
            content: content,
            backgroundColor: nil,
            alignment: .left,
            childrenIds: [],
            fields: [:]
        )
    }
}

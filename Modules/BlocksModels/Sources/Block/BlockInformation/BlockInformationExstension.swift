public extension BlockInformation {
    static func emptyText(blockId: BlockId = "") -> BlockInformation {
        BlockInformation(blockId: blockId, content: .text(.empty))
    }
}

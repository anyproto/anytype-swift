import BlocksModels

enum OurEvent {
    case setFocus(blockId: BlockId, position: BlockFocusPosition)
    case setTextMerge(blockId: BlockId)
    case setToggled(blockId: BlockId)
}

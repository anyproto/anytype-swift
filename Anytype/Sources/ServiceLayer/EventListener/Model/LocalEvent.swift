import BlocksModels

enum LocalEvent {
    case setFocus(blockId: BlockId, position: BlockFocusPosition)
    case setTextMerge(blockId: BlockId)
    case setToggled(blockId: BlockId)
    case setText(blockId: BlockId, text: String)
}

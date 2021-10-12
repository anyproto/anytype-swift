import BlocksModels

enum LocalEvent {
    case setFocus(blockId: BlockId, position: BlockFocusPosition)
    case setToggled(blockId: BlockId)
    case setText(blockId: BlockId, text: String)
    case setLoadingState(blockId: BlockId)
    case reload(blockId: BlockId)
}

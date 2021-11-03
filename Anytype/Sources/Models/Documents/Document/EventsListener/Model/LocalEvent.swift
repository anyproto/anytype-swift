import BlocksModels

enum LocalEvent {
    case setFocus(blockId: BlockId, position: BlockFocusPosition)
    case setToggled(blockId: BlockId)
    case setText(blockId: BlockId, text: MiddlewareString)
    case setLoadingState(blockId: BlockId)
    case reload(blockId: BlockId)
    case documentClosed(blockId: BlockId)
}

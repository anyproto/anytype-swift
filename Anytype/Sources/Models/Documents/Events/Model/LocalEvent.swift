import BlocksModels
import AnytypeCore

enum LocalEvent {
    case setStyle(blockId: AnytypeId)
    case setToggled(blockId: BlockId)
    case setText(blockId: BlockId, text: MiddlewareString)
    case setLoadingState(blockId: BlockId)
    case reload(blockId: BlockId)
    case documentClosed(blockId: BlockId)
    case header(ObjectHeaderUpdate)
}

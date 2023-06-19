import Services
import AnytypeCore

enum LocalEvent {
    case general
    case setStyle(blockId: BlockId)
    case setToggled(blockId: BlockId)
    case setText(blockId: BlockId, text: MiddlewareString)
    case setLoadingState(blockId: BlockId)
    case reload(blockId: BlockId)
    case header(ObjectHeaderUpdate)
}

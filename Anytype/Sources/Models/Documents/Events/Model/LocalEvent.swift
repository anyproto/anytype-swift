import Services
import AnytypeCore
import Services

enum LocalEvent {
    case general
    case setStyle(blockId: BlockId)
    case setToggled(blockId: BlockId)
    case setText(blockId: BlockId, text: MiddlewareString)
    case setLoadingState(blockId: BlockId)
    case reload(blockId: BlockId)
}

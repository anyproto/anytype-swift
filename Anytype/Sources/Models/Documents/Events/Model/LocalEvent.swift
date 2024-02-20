import Services
import AnytypeCore
import Services

enum LocalEvent {
    case general
    case setStyle(blockId: String)
    case setToggled(blockId: String)
    case setText(blockId: String, text: MiddlewareString)
    case setLoadingState(blockId: String)
    case reload(blockId: String)
}

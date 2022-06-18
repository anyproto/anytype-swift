import BlocksModels
import Combine

protocol TextBlockActionHandlerProtocol {
    var resetSubject: PassthroughSubject<BlockText, Never> { get }

    func textBlockActions() -> TextBlockContentConfiguration.Actions
}

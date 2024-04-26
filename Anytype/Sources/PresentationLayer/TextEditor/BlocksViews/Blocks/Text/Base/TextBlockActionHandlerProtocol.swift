import Services
import Combine

protocol TextBlockActionHandlerProtocol {
    var resetSubject: PassthroughSubject<Void, Never> { get }

    func textBlockActions() -> TextBlockContentConfiguration.Actions
}

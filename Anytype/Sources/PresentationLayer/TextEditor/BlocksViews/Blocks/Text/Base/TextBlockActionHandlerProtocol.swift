import Services
import Combine
import Foundation

protocol TextBlockActionHandlerProtocol: AnyObject {
    var info: BlockInformation { get set }
    
    var resetSubject: PassthroughSubject<NSAttributedString?, Never> { get }
    var focusSubject: PassthroughSubject<BlockFocusPosition, Never> { get }

    func textBlockActions() -> TextBlockContentConfiguration.Actions
}

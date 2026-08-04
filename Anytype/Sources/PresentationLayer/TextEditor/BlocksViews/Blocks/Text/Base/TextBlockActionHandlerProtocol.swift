import Services
import Combine
import Foundation


@MainActor
protocol TextBlockActionHandlerProtocol: AnyObject {
    var info: BlockInformation { get set }

    var resetSubject: PassthroughSubject<NSAttributedString?, Never> { get }
    var focusSubject: PassthroughSubject<BlockFocusPosition, Never> { get }

    func textBlockActions() -> TextBlockContentConfiguration.Actions
    /// Undo restored the block this handler forked away from; a completed or in-flight fork
    /// must not gate a fresh first fill nor rebind to the deleted id.
    func resetEmptyBlockFork()
}

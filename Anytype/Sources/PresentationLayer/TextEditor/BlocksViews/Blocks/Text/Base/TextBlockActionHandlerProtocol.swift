import Services
import Combine
import Foundation


@MainActor
protocol TextBlockActionHandlerProtocol: AnyObject {
    var info: BlockInformation { get set }

    var resetSubject: PassthroughSubject<NSAttributedString?, Never> { get }
    var focusSubject: PassthroughSubject<BlockFocusPosition, Never> { get }

    func textBlockActions() -> TextBlockContentConfiguration.Actions
    /// Forgets a completed empty-block identity fork after undo restored the replaced block;
    /// see TextBlockViewModel.rebindAfterIdentityUndo. No-op for handlers that never fork.
    func resetEmptyBlockFork()
}

extension TextBlockActionHandlerProtocol {
    func resetEmptyBlockFork() {}
}

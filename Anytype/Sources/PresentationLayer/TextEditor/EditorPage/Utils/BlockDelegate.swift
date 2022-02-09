import BlocksModels
import AnytypeCore

protocol BlockDelegate: AnyObject {
    func willBeginEditing(data: TextBlockDelegateData)
    func didBeginEditing()
    func didEndEditing(data: TextBlockDelegateData)

    func textWillChange(changeType: TextChangeType)
    func textDidChange(data: TextBlockDelegateData)
    func textBlockSetNeedsLayout()
    func selectionDidChange(range: NSRange)
}

final class BlockDelegateImpl: BlockDelegate {
    private var changeType: TextChangeType?

    weak private var viewInput: EditorPageViewInput?

    private let accessoryState: AccessoryViewStateManager
    private let markdownListener: MarkdownListener
    
    init(
        viewInput: EditorPageViewInput?,
        accessoryState: AccessoryViewStateManager,
        markdownListener: MarkdownListener
    ) {
        self.viewInput = viewInput
        self.accessoryState = accessoryState
        self.markdownListener = markdownListener
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing(data: TextBlockDelegateData) {
        viewInput?.textBlockWillBeginEditing()
        accessoryState.willBeginEditing(data: data)
    }
    
    func didEndEditing(data: TextBlockDelegateData) {
        viewInput?.blockDidFinishEditing(blockId: data.info.id)
        accessoryState.didEndEditing()
    }
    
    func textWillChange(changeType: TextChangeType) {
        self.changeType = changeType
    }
    
    func textDidChange(data: TextBlockDelegateData) {
        viewInput?.textBlockDidChangeText()

        guard let changeType = changeType else { return }

        accessoryState.textDidChange(changeType: changeType)
        markdownListener.textDidChange(changeType: changeType, data: data)
    }

    func textBlockSetNeedsLayout() {
        viewInput?.textBlockDidChangeFrame()
    }

    func selectionDidChange(range: NSRange) {
        accessoryState.selectionDidChange(range: range)
    }
}

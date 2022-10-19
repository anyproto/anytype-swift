import BlocksModels
import AnytypeCore
import UIKit

protocol BlockDelegate: AnyObject {
    func willBeginEditing(data: TextBlockDelegateData)
    func didBeginEditing(view: UIView)
    func didEndEditing(data: TextBlockDelegateData)

    func textWillChange(changeType: TextChangeType)
    func textDidChange(data: TextBlockDelegateData)
    func textBlockSetNeedsLayout()
    func selectionDidChange(data: TextBlockDelegateData, range: NSRange)
    func scrollToBlock(blockId: BlockId)
}

final class BlockDelegateImpl: BlockDelegate {
    private var changeType: TextChangeType?

    weak private var viewInput: EditorPageViewInput?

    private let accessoryState: AccessoryViewStateManager
    private let cursorManager: EditorCursorManager
    
    init(
        viewInput: EditorPageViewInput?,
        accessoryState: AccessoryViewStateManager,
        cursorManager: EditorCursorManager
    ) {
        self.viewInput = viewInput
        self.accessoryState = accessoryState
        self.cursorManager = cursorManager
    }

    func didBeginEditing(view: UIView) {
        viewInput?.textBlockDidBeginEditing(firstResponderView: view)
    }

    func willBeginEditing(data: TextBlockDelegateData) {
        viewInput?.textBlockWillBeginEditing()
        accessoryState.willBeginEditing(data: data)
    }
    
    func didEndEditing(data: TextBlockDelegateData) {
        viewInput?.blockDidFinishEditing(blockId: data.info.id)
        accessoryState.didEndEditing(data: data)
    }
    
    func textWillChange(changeType: TextChangeType) {
        self.changeType = changeType
    }
    
    func textDidChange(data: TextBlockDelegateData) {
        viewInput?.textBlockDidChangeText()

        guard let changeType = changeType else { return }

        accessoryState.textDidChange(changeType: changeType)
    }

    func textBlockSetNeedsLayout() {
        viewInput?.blockDidChangeFrame()
    }

    func selectionDidChange(data: TextBlockDelegateData, range: NSRange) {
        accessoryState.selectionDidChange(range: range)
        cursorManager.didChangeCursorPosition(at: data.info.id, position: .at(range))
        viewInput?.didSelectTextRangeSelection(blockId: data.info.id, textView: data.textView)
    }
    
    func scrollToBlock(blockId: BlockId) {
        viewInput?.scrollToBlock(blockId: blockId)
    }
}

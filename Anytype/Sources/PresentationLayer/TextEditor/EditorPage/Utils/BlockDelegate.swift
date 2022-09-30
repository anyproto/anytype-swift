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
    
    init(
        viewInput: EditorPageViewInput?,
        accessoryState: AccessoryViewStateManager
    ) {
        self.viewInput = viewInput
        self.accessoryState = accessoryState
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
        viewInput?.didChangeSelection(blockId: data.info.id)
    }
    
    func scrollToBlock(blockId: BlockId) {
        viewInput?.scrollToBlock(blockId: blockId)
    }
}

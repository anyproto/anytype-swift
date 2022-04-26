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
    func selectionDidChange(range: NSRange)
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
        viewInput?.blockDidFinishEditing(blockId: data.info.id.value)
        accessoryState.didEndEditing()
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
        viewInput?.textBlockDidChangeFrame()
    }

    func selectionDidChange(range: NSRange) {
        accessoryState.selectionDidChange(range: range)
    }
}

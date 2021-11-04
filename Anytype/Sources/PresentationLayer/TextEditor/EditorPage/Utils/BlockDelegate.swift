import BlocksModels

protocol BlockDelegate: AnyObject {
    func willBeginEditing(data: TextBlockDelegateData)
    func didBeginEditing()
    func didEndEditing()
    
    func becomeFirstResponder(blockId: BlockId)
    func resignFirstResponder(blockId: BlockId)
    
    func textWillChange(changeType: TextChangeType)
    func textDidChange()
}

final class BlockDelegateImpl: BlockDelegate {
    
    private var changeType: TextChangeType?
    private var data: TextBlockDelegateData?
    
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

    func becomeFirstResponder(blockId: BlockId) {
        UserSession.shared.firstResponderId.value = blockId
    }
    
    func resignFirstResponder(blockId: BlockId) {
        UserSession.shared.resignFirstResponder(blockId: blockId)
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing(data: TextBlockDelegateData) {
        self.data = data
        viewInput?.textBlockWillBeginEditing()
        accessoryState.willBeginEditing(data: data)
    }
    
    func didEndEditing() {
        data = nil
        accessoryState.didEndEditing()
    }
    
    func textWillChange(changeType: TextChangeType) {
        self.changeType = changeType
    }
    
    func textDidChange() {
        guard let changeType = changeType else { return }
        guard let data = data else { return }

        accessoryState.textDidChange(changeType: changeType)
        markdownListener.textDidChange(changeType: changeType, data: data)
    }
}

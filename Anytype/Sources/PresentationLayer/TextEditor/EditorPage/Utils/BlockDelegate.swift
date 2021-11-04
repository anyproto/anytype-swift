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
    private let accessoryDelegate: AccessoryTextViewDelegate
    
    init(
        viewInput: EditorPageViewInput?,
        accessoryDelegate: AccessoryTextViewDelegate
    ) {
        self.viewInput = viewInput
        self.accessoryDelegate = accessoryDelegate
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
        accessoryDelegate.willBeginEditing(data: data)
    }
    
    func didEndEditing() {
        data = nil
        accessoryDelegate.didEndEditing()
    }
    
    func textWillChange(changeType: TextChangeType) {
        self.changeType = changeType
    }
    
    func textDidChange() {
        guard let changeType = changeType else {
            return
        }

        accessoryDelegate.textDidChange(changeType: changeType)
    }
}

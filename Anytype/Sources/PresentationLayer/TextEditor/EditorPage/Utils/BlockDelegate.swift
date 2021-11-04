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
    weak private(set) var viewInput: EditorPageViewInput?
    let document: BaseDocumentProtocol
    private let accessoryDelegate: AccessoryTextViewDelegate
    
    init(
        viewInput: EditorPageViewInput?,
        document: BaseDocumentProtocol,
        accessoryDelegate: AccessoryTextViewDelegate
    ) {
        self.viewInput = viewInput
        self.document = document
        self.accessoryDelegate = accessoryDelegate
    }

    func becomeFirstResponder(blockId: BlockId) {
        UserSession.shared.firstResponderId.value = blockId
    }
    
    func resignFirstResponder(blockId: BlockId) {
        if UserSession.shared.firstResponderId.value == blockId {
            UserSession.shared.firstResponderId.value = nil
        }
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing(data: TextBlockDelegateData) {
        viewInput?.textBlockWillBeginEditing()
        accessoryDelegate.willBeginEditing(data: data)
    }
    
    func didEndEditing() {
        accessoryDelegate.didEndEditing()
    }
    
    func textWillChange(changeType: TextChangeType) {
        accessoryDelegate.textWillChange(changeType: changeType)
    }
    
    func textDidChange() {
        accessoryDelegate.textDidChange()
    }
}

import BlocksModels


protocol BlockDelegate: AnyObject {
    func becomeFirstResponder(blockId: BlockId)
    func resignFirstResponder(blockId: BlockId)
    func didBeginEditing()
    func willBeginEditing()
}

final class BlockDelegateImpl: BlockDelegate {
    weak private(set) var viewInput: EditorPageViewInput?
    let document: BaseDocumentProtocol
    
    init(
        viewInput: EditorPageViewInput?,
        document: BaseDocumentProtocol
    ) {
        self.viewInput = viewInput
        self.document = document
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

    func willBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
}

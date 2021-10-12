import BlocksModels


protocol BlockDelegate: AnyObject {
    func blockSizeChanged()
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
    
    func blockSizeChanged() {
        viewInput?.needsUpdateLayout()
    }

    func becomeFirstResponder(blockId: BlockId) {
        UserSession.shared.firstResponderId = blockId
    }
    
    func resignFirstResponder(blockId: BlockId) {
        if UserSession.shared.firstResponderId == blockId {
            UserSession.shared.firstResponderId = nil
        }
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
}

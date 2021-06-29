import BlocksModels


/// Delegate for base block
protocol BlockDelegate: AnyObject {
    /// Called when block size changed
    func blockSizeChanged()
    /// Block become first responder
    func becomeFirstResponder(for block: BlockModelProtocol)
    /// Tells the delegate when editing of the block begins
    func didBeginEditing()
    /// Tells the delegate when editing of the block will begin
    func willBeginEditing()
}

class BlockDelegateImpl: BlockDelegate {
    weak private(set) var viewInput: EditorModuleDocumentViewInput?
    let document: BaseDocumentProtocol
    
    init(
        viewInput: EditorModuleDocumentViewInput?,
        document: BaseDocumentProtocol
    ) {
        self.viewInput = viewInput
        self.document = document
    }
    
    func blockSizeChanged() {
        viewInput?.needsUpdateLayout()
    }

    func becomeFirstResponder(for block: BlockModelProtocol) {
        document.userSession?.setFirstResponder(with: block)
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
}

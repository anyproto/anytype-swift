import BlocksModels


/// Delegate for base block
protocol BlockDelegate: AnyObject {
    /// Called when block size changed
    func blockSizeChanged()
    /// Block become first responder
    func becomeFirstResponder(for block: BlockModelProtocol)
    /// First responder resigned
    func resignFirstResponder()
    /// Tells the delegate when editing of the block begins
    func didBeginEditing()
    /// Tells the delegate when editing of the block will begin
    func willBeginEditing()
}

final class BlockDelegateImpl: BlockDelegate {
    weak private(set) var viewInput: DocumentEditorViewInput?
    let document: BaseDocumentProtocol
    
    init(
        viewInput: DocumentEditorViewInput?,
        document: BaseDocumentProtocol
    ) {
        self.viewInput = viewInput
        self.document = document
    }
    
    func blockSizeChanged() {
        viewInput?.needsUpdateLayout()
    }

    func becomeFirstResponder(for block: BlockModelProtocol) {
        document.userSession?.firstResponder = block
    }
    
    func resignFirstResponder() {
        document.userSession?.firstResponder = nil
    }

    func didBeginEditing() {
        viewInput?.textBlockDidBeginEditing()
    }

    func willBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
}

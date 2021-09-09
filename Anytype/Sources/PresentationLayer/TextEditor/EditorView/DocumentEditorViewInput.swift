import BlocksModels


/// Input data for document view
protocol DocumentEditorViewInput: AnyObject {
    
    func updateHeader(_ header: ObjectHeader, details: DetailsDataProtocol?)
    func updateBlocks(_ blocks: [BlockViewModelProtocol])
    
    func selectBlock(blockId: BlockId)

    /// Ask view rebuild layout
    func needsUpdateLayout()

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()
}

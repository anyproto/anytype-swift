import BlocksModels


/// Input data for document view
protocol EditorPageViewInput: AnyObject {
    
    func update(header: ObjectHeader, details: DetailsDataProtocol?)
    func update(blocks: [BlockViewModelProtocol])
    func update(syncStatus: SyncStatus)
    
    func selectBlock(blockId: BlockId)

    /// Ask view rebuild layout
    func needsUpdateLayout()

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()
}

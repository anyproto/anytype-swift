import BlocksModels


/// Input data for document view
protocol EditorPageViewInput: AnyObject {
    
    func update(header: ObjectHeader, details: ObjectDetails?)
    func update(blocks: [BlockViewModelProtocol])
    func update(syncStatus: SyncStatus)
    
    func selectBlock(blockId: BlockId)
    
    func showDeletedScreen(_ show: Bool)

    /// Ask view rebuild layout
    func needsUpdateLayout()

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()
}
